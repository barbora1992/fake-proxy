require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/namespace'
require 'sinatra/contrib/all'
require 'yaml'
require 'sinatra/base'
require 'sinatra/flash'
require 'securerandom'
require 'pry'
require 'logger' 
require "sinatra/streaming"
require 'rest-client'

require './modules/module_puppetca.rb'
require './modules/module_dhcp.rb'
require './modules/module_dns.rb'
require './modules/module_puppet_proxy.rb'
require './modules/module_tftp.rb'


require_relative "task"
require_relative "taskqueue"
require_relative "import/taskresponsequeue"
require_relative "import/taskresponse"

set :bind, '0.0.0.0'
enable :logging 
enable :sessions

$logger = Logger.new('/tmp/app.error.log')
$buffer = TaskQueue.new
$responses = TaskResponseQueue.new
$modules =  ["logs","puppetca", "dhcp", "tftp", "puppet"]
@message = "Hello"

$preload = Array.new
#$preload = [Task.new("/puppet/ca","GET", nil), Task.new("/puppet/ca/autosign","GET", nil), Task.new("/dhcp/?","GET", nil), Task.new("/puppet/run","POST", nil), Task.new("/puppet/environments","GET", nil), Task.new("/tftp/serverName","GET", nil)]
$preload = [Task.new("/puppet/ca","GET", nil), Task.new("/puppet/ca/autosign","GET", nil)]
	
def reply_or_create_task(log_message)
  action = request.env['PATH_INFO']
  method = request.env['REQUEST_METHOD']
  parameters = request.env['QUERY_STRING']
  r = $responses.find_by_query_and_method(action, method)
  if r.nil? 
    $logger.info(log_message)
    t = Task.new(action, method, parameters)
    $buffer.enqueue(t)
    content_type 'application/json'
    response.status = 503
  else  
    reply = r.response
    $responses.delete_task_by_uuid(r.uuid)
    $buffer.delete_task_by_uuid(r.uuid)
    reply 
  end
end

#***********************RESPONSES***************************************************
get '/upload' do
  erb :upload
end

post '/responses' do #this should work
  content = File.read(params[:file][:tempfile])
  items = Array.new
  items = YAML.load(content)
  items.each do |item| 
    tmp = TaskResponse.new(item.response, item.query, item.uuid, item.status, item.method)
    if $buffer.task_exists(tmp.uuid)
      $responses.delete_task_by_uuid(tmp.uuid) #purge old versions by uuid, no need to store time in task respons, it just deletes all of them, stores the newest one
      $responses.enqueue(tmp)
    end
  end
  redirect '/response_table'
end

#get '/response_list' do
#  erb :response_list, :locals => { :responses => $responses } 
#end

get '/response_table' do
  erb :response_table, :locals => { :responses => $responses } 
end

##################################WEBUI######################################################

get '/' do 
  erb :webui, :locals => { :message => $message } 
end

get "/features" do 
  $logger.info('Listing features')	        
  $modules.to_json
end

get "/version" do 
  $logger.info('Listing version')
  version = '{"version":"1.14.0-develop","modules":{'+ $modules.map{ |x| {x => "1.14.0"}}.to_json.tr("[]{}", "") + "}}" 
end

get "/logs/" do #TODO it just doesnt want to work - it used to, but now it doesnt
  $logger.info('Listing logs')
  content_type :json 
  records = File.read('/tmp/app.error.log').split("\n")
  records.shift
  records.reverse!
  parsed = Array.new
  records.each do |line|
    msg = line.split(':')[-1]
    hash = {:timestamp => Time.now.to_f, :level => "INFO", :message => msg}
    parsed.push(hash)
  end
  '{"info":{"failed_modules":{}},"logs":' + parsed.to_json + '}'
end

get '/clear' do #delete 'tasks'
  $buffer.clear
  $responses.clear
  @message = session[:message] = 'All tasks were deleted'
  erb :webui, :locals => { :message => $message }
end

get '/tasks' do #get 'tasks'
  erb :list, :locals => { :buffer => $buffer } 
end

get '/file' do 
  $buffer.mark_tasks_saved
  content_type 'plain/text'
  attachment "tasks.yaml"
  $buffer.to_yaml
  #@message = session[:message] = 'List was saved' #will return webui.erb
  #erb :webui, :locals => { :message => $message }
end

get '/delete_by_uuid' do 
  erb :deleteuuid
end

post '/delete_task_by_uuid' do #we will delete also a response if exists
  u = params[:uuid]
  $buffer.delete_task_by_uuid(u)
  $responses.delete_task_by_uuid(u)
  @message = session[:message] = 'Task was deleted'
  erb :webui, :locals => { :message => $message }
end

get '/preload' do 
  $preload.each do |item| 
    $buffer.enqueue(item)
    $logger.info('Task ' + item.method + " " + item.action + ' was preloaded') 
  end
  @message = session[:message] = 'Tasks were preloaded'
  erb :webui, :locals => { :message => $message }
end


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

load 'modules/module_puppetca.rb'
load 'modules/module_dhcp.rb'
load 'modules/module_dns.rb'
load 'modules/module_puppet_proxy.rb'
load 'modules/module_tftp.rb'


require_relative "task"
require_relative "taskqueue"
require_relative "import/taskresponsequeue"
require_relative "import/taskresponse"

set :bind, '0.0.0.0'
enable :logging #works

$logger = Logger.new('/tmp/app.error.log')
$buffer = TaskQueue.new
$responses = TaskResponseQueue.new
$modules =  ["logs","puppetca", "dhcp", "tftp", "puppet"]

def reply_or_create_task(parameters, method, log_message)
  action = request.env['PATH_INFO']
  r = $responses.find_by_query_and_method(action, method)
  if r == nil 
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

get '/test/:aaa' do
  #action = request.env['PATH_INFO'] # + "?" + request.env['QUERY_STRING']
  arr = params[:aaa]
  reply_or_create_task(arr, 'get', 'fail')
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
  redirect '/responselist'
end

get '/responselist' do
  erb :responselist, :locals => { :responses => $responses } 
end

##################################WEBUI######################################################

get '/' do 
  erb :webui
end

get "/features" do 
  $logger.info('listing features')	        
  $modules.to_json
end

get "/version" do 
  $logger.info('listing version')
  version = '{"version":"1.14.0-develop","modules":{'+ $modules.map{ |x| {x => "1.14.0"}}.to_json.tr("[]{}", "") + "}}" 
end

get "/logs/" do #TODO it just doesnt want to work - it used to, but now it doesnt
  $logger.info('listing logs')
  content_type :json 
  #$logger.to_json
  #binding.pry 
  #{"logs": $logger.to_json }
  records = File.read('/tmp/app.error.log').split("\n")
  #'{}'
end

get '/clear' do #delete 'tasks'
  $buffer.clear
  $responses.clear
  erb :success
end

get '/tasks' do #get 'tasks'
  erb :list, :locals => { :buffer => $buffer } 
end

get '/file' do 
  $buffer.mark_tasks_saved
  content_type 'plain/text'
  attachment "tasks.yaml"
  $buffer.to_yaml
end

get '/delete_by_uuid' do 
  erb :deleteuuid
end

post '/delete_task_by_uuid' do #we will delete also a response if exists
  u = params[:uuid]
  $buffer.delete_task_by_uuid(u)
  $responses.delete_task_by_uuid(u)
  redirect '/'
end

get '/preload' do 
  t = Task.new("/puppet/ca","get", nil)
  $buffer.enqueue(t)
  s = Task.new("/puppet/ca/autosign","get", nil) 
  $buffer.enqueue(s)
  #get "/dhcp/?"
  #post "/run" do
  #get "/environments" do
  #get "/tftp/serverName"
  redirect '/'
end


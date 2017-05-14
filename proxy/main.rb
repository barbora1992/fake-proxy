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

require "./lib/task.rb"
require "./lib/taskqueue.rb"
require "./lib/taskresponse.rb"
require "./lib/taskresponsequeue.rb"

set :bind, '0.0.0.0'
enable :logging 
enable :sessions

$logger = Logger.new('/tmp/app.error.log')
$task_buffer = TaskQueue.new
$response_buffer = TaskResponseQueue.new
#$modules =  ["logs","puppetca", "dhcp", "tftp", "puppet"]
$modules =  ["logs","puppetca"]

$preload = [{ "action" => "/puppet/ca", "method" => "GET", "parameters" => nil }, { "action" => "/puppet/ca/autosign", "method" => "GET", "parameters" => nil } ]
	
def reply_or_create_task(log_message)
  action = request.env['PATH_INFO']
  method = request.env['REQUEST_METHOD']
  parameters = request.env['QUERY_STRING']
  r = $response_buffer.find_by_query_method_parameters(action, method, parameters)
  if r.nil? 
    $logger.info(log_message)
    t = Task.new(action, method, parameters)
    $task_buffer.enqueue(t)
    content_type 'application/json'
    if method == "GET"
      response.status = 503
    else 
      response.status = 202
    end
  else  
    reply = r.response
    $response_buffer.delete_task_by_uuid(r.uuid)
    $task_buffer.delete_task_by_uuid(r.uuid)
    reply 
  end
end


##################################WEBUI######################################################

get '/' do 
  $message = session[:message] = ' '
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

get "/logs/" do 
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

get '/clear' do 
  $task_buffer.clear
  $response_buffer.clear
  $message = session[:message] = 'All tasks were deleted'
  erb :webui, :locals => { :message => $message }
end

get '/tasks' do
  erb :task_table, :locals => { :task_buffer => $task_buffer } 
end

get '/download' do 
  $task_buffer.mark_tasks_saved
  content_type 'plain/text'
  attachment "tasks.yaml"
  $task_buffer.to_yaml
end

get '/delete_by_uuid' do 
  erb :delete_by_uuid
end

post '/delete_task_by_uuid' do 
  u = params[:uuid]
  $task_buffer.delete_task_by_uuid(u)
  $response_buffer.delete_task_by_uuid(u)
  $message = session[:message] = 'Task was deleted'
  erb :webui, :locals => { :message => $message }
end

get '/preload' do 
  $preload.each do |item|
    task = Task.new(item['action'], item['method'], item['parameters'])    
    $task_buffer.enqueue(task)
    $logger.info('Task ' + item['method'] + " " + item['action']+ ' was preloaded') 
  end
  $message = session[:message] = 'Tasks were preloaded'
  erb :webui, :locals => { :message => $message }
end

get '/upload' do
  erb :upload
end

post '/responses' do 
  content = File.read(params[:file][:tempfile])
  items = Array.new
  items = YAML.load(content)
  items.each do |item| 
    tmp = TaskResponse.new(item.response, item.query, item.parameters, item.uuid, item.status, item.method)
    if $task_buffer.task_exists(tmp.uuid)
      $response_buffer.delete_task_by_uuid(tmp.uuid) #purge old versions by uuid, no need to store time in task response, it just deletes all of them, stores the newest one
      $response_buffer.enqueue(tmp)
    end
  end
  redirect '/response_table'
end

get '/response_table' do
  erb :response_table, :locals => { :response_buffer => $response_buffer } 
end


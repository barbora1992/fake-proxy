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

require_relative "task"
require_relative "taskqueue"
require_relative "import/taskresponsequeue"
require_relative "import/taskresponse"

set :bind, '0.0.0.0'
enable :logging #works
#set :logger #nope

logger = Logger.new('/tmp/app.error.log')
buffer = TaskQueue.new
responses = TaskResponseQueue.new
que = Array.new

#***********************RESPONSES***************************************************
get '/upload' do
  erb :upload
end

post '/responses' do 
  u = params[:filename]
  #load_responses(u)
  if File.file?(u)
    items = Array.new
    items = YAML.load_file(u)
    items.each do |item|
      if buffer.task_exists(item.uuid)
        buffer.delete_task_by_uuid(item.uuid) #purge old versions by uuid, no need to store time in task response, it just deletes all of them, stores the newest one
        tmp = TaskResponse.new(item.response, item.query, item.uuid, item.status, item.method)
        responses.enqueue(tmp)
      end
    end
  else 
    erb :error
  end
  responses.to_yaml
end

get '/responselist' do
  erb :responselist, :locals => { :responses => responses } 
end

##################################WEBUI######################################################

get '/' do 
  erb :webui
end

get "/features" do 
  logger.info('listing features')	        
  '["logs","puppetca"]'
end

get "/version" do 
  logger.info('listing version')
  '{"version":"1.14.0-develop","modules":{"puppetca":"1.14.0","logs":"1.14.0"}}' #imaginary
end

get "/logs/" do #TODO it just doesnt want to work - it used to, but now it doesnt
  logger.info('listing logs')
  content_type :json 
  #logger.to_json
  #binding.pry 
  {"logs": logger.to_json }
  #'{}'
end

get '/clear' do #delete 'tasks'
  buffer.clear
  erb :success
end

get '/tasks' do #get 'tasks'
  erb :list, :locals => { :buffer => buffer } 
end

get '/file' do 
  buffer.mark_tasks_saved
  content_type 'plain/text'
  attachment "tasks.yaml"
  buffer.to_yaml
end

get '/delete_by_uuid' do 
  erb :deleteuuid
end

post '/delete_task_by_uuid' do 
  u = params[:uuid]
  buffer.delete_task_by_uuid(u)
  redirect '/'
end

get '/preload' do 
  t = Task.new("/puppet/ca","get", nil)
  buffer.enqueue(t)
  s = Task.new("/puppet/ca/autosign","get", nil) 
  buffer.enqueue(s)
  redirect '/'
end

###############################PUPPETCA#####################################################

get "/puppet/ca" do 
  r = responses.find_by_query("/puppet/ca")
  if r == nil 
    logger.info('Failed to list certificates')
    t = Task.new("/puppet/ca","get", nil)
    buffer.enqueue(t)
    #"{}" #this works
    content_type 'application/json' #thats how smart-proxy replies
    response.status = 503
    else 
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
  
end

get "/puppet/ca/autosign" do #list of all puppet autosign entires
  r = responses.find_by_query("/puppet/ca/autosign")
  if r == nil 
    logger.info('Failed to list puppet autosign entries')
    t = Task.new("/puppet/ca/autosign","get", nil)
    buffer.enqueue(t)
    content_type 'application/json' #thats how smart-proxy replies
    response.status = 503
    #"{}" #this works
    else 
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

########

post "/puppet/ca/autosign/:certname" do #Add certname to Puppet autosign
  arr = params[:certname]
  r = responses.find_by_query_and_method("/puppet/ca/autosign/"+arr, "post")
  if r == nil 
    logger.info('Failed to add certname to Puppet autosign')
    t = Task.new("/puppet/ca/autosign/"+arr,"post", arr)
    buffer.enqueue(t)
    content_type 'application/json' #thats how smart-proxy replies
    response.status = 503
    else
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

delete "/puppet/ca/autosign/:certname" do #Remove certname from Puppet autosign	
  arr = params[:certname]
  r = responses.find_by_query_and_method("/puppet/ca/autosign/"+arr, "delete")
  if r == nil 
    logger.info('Failed to delete certname from Puppet autosign')
    t = Task.new("/puppet/ca/autosign/"+arr,"delete", arr)
    buffer.enqueue(t)
    content_type 'application/json'
    response.status = 503
    else  
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

##########

post "/puppet/ca/:certname" do #Sign pending certificate request
  arr = params[:certname]
  r = responses.find_by_query_and_method("/puppet/ca/"+arr, "post")
  if r == nil 
    logger.info('Failed to sign certname')
    t = Task.new("/puppet/ca/"+arr,"post", arr)
    buffer.enqueue(t)
    content_type 'application/json'
    response.status = 503
    else  
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

delete "/puppet/ca/:certname" do #Remove (clean) and revoke a certificate
  arr = params[:certname]
  r = responses.find_by_query_and_method("/puppet/ca/"+arr, "delete")
  if r == nil 
    logger.info('Failed to delete certname')
    t = Task.new("/puppet/ca/"+arr,"delete", arr)
    buffer.enqueue(t)
    content_type 'application/json'
    response.status = 503
    else  
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

###############################DHCP#####################################################

get "/dhcp/?" do
  r = responses.find_by_query("/dhcp/?")
  if r == nil 
    logger.info('Failed to get dhcp')
    t = Task.new("/dhcp/?","get", nil)
    buffer.enqueue(t)
    content_type 'application/json' #thats how smart-proxy replies
    response.status = 503
    #"{}" #this works
    else 
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

get "/dhcp/:network" do
  arr = params[:network]
  r = responses.find_by_query_and_method("/dhcp/"+arr, "get")
  if r == nil 
    logger.info('Failed')
    t = Task.new("/dhcp/"+arr,"get", arr)
    buffer.enqueue(t)
    content_type 'application/json'
    response.status = 503
    else  
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

get "/dhcp/:network/unused_ip" do
end

get "/dhcp/:network/:record" do  # Deprecated, returns a single record
end

get "/dhcp/:network/ip/:ip_address" do # returns an array of records for an ip address
end

get "/dhcp/:network/mac/:mac_address" do  # returns a record for a mac address
end
 
post "/dhcp/:network" do  # create a new record in a network
  arr = params[:network]
  r = responses.find_by_query_and_method("/dhcp/"+arr, "post")
  if r == nil 
    logger.info('Failed')
    t = Task.new("/dhcp/"+arr,"post", arr)
    buffer.enqueue(t)
    content_type 'application/json'
    response.status = 503
    else  
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

delete "/dhcp/:network/:record" do  # deprecated, delete a record from a network
end

delete "/dhcp/:network/ip/:ip_address" do  # deletes all records for an ip address from a network
end

delete "/dhcp/:network/mac/:mac_address" do  # delete a record for a mac address from a network
end

###############################DNS#####################################################

post "/dns/?" do
  r = responses.find_by_query("/dns/?")
  if r == nil 
    logger.info('Failed to post dns')
    t = Task.new("/dns/?","post", nil)
    buffer.enqueue(t)
    content_type 'application/json' #thats how smart-proxy replies
    response.status = 503
    #"{}" #this works
    else 
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

delete '/dns/:value/?:type?' do
end

###############################PUPPET_PROXY########################################### #neviem aky prefix - /proxy? /smart-proxy? /puppet-proxy? podla api je to *asi* /puppet ? 

post "/run" do
  r = responses.find_by_query("/run")
  if r == nil 
    logger.info('Failed to run proxy')
    t = Task.new("/run","post", nil)
    buffer.enqueue(t)
    content_type 'application/json' #thats how smart-proxy replies
    response.status = 503
    #"{}" #this works
    else 
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

get "/environments" do
  r = responses.find_by_query("/environments")
  if r == nil 
    logger.info('Failed to get environments')
    t = Task.new("/environments","get", nil)
    buffer.enqueue(t)
    content_type 'application/json' #thats how smart-proxy replies
    response.status = 503
    #"{}" #this works
    else 
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

get "/environments/:environment" do

end

get "/environments/:environment/classes" do
end

get "/environments/:environment/classes_and_errors" do
end

###############################TFTP#####################################################

post "/tftp/fetch_boot_file" do
  r = responses.find_by_query("/tftp/fetch_boot_file")
  if r == nil 
    logger.info('Failed to fetch boot file')
    t = Task.new("/tftp/fetch_boot_file","post", nil)
    buffer.enqueue(t)
    content_type 'application/json' #thats how smart-proxy replies
    response.status = 503
    #"{}" #this works
    else 
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

post "/tftp/:variant/create_default" do |variant|
end

get "/tftp/:variant/:mac" do |variant, mac|
end

post "/tftp/:variant/:mac" do |variant, mac|
end

delete "/tftp/:variant/:mac" do |variant, mac|
end

post "/tftp/create_default" do
  r = responses.find_by_query("/tftp/create_default")
  if r == nil 
    logger.info('Failed to create default')
    t = Task.new("/tftp/create_default","post", nil)
    buffer.enqueue(t)
    content_type 'application/json' #thats how smart-proxy replies
    response.status = 503
    #"{}" #this works
    else 
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

post "/tftp/:mac" do |mac|
  arr = params[:mac]
  r = responses.find_by_query_and_method("/tftp/"+arr, "post")
  if r == nil 
    logger.info('Failed')
    t = Task.new("/tftp/"+arr,"post", arr)
    buffer.enqueue(t)
    content_type 'application/json'
    response.status = 503
    else  
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

delete "/tftp/:mac" do |mac|
  arr = params[:mac]
  r = responses.find_by_query_and_method("/tftp/"+arr, "delete")
  if r == nil 
    logger.info('Failed')
    t = Task.new("/tftp/"+arr,"post", arr)
    buffer.enqueue(t)
    content_type 'application/json'
    response.status = 503
    else  
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

get "/tftp/serverName" do
  r = responses.find_by_query("/tftp/serverName")
  if r == nil 
    logger.info('Failed to get server name')
    t = Task.new("/tftp/serverName","get", nil)
    buffer.enqueue(t)
    content_type 'application/json' #thats how smart-proxy replies
    response.status = 503
    #"{}" #this works
    else 
      reply = r.response
      responses.delete_task_by_uuid(r.uuid)
      buffer.delete_task_by_uuid(r.uuid)
      reply 
  end
end

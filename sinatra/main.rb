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

enable :sessions
register Sinatra::Flash
set :bind, '0.0.0.0'
enable :logging #works
#set :logger #nope
require 'logger'
logger = Logger.new('/home/barbora/fake-proxy/sinatra/app.error.log')
require './puppet.rb'
register Puppet

taskarray = Array.new
#taskarray2 = Array.new

#****************Class Task
class Task 
  def initialize(type, operation, param, date, status) #typ (napr /puppet/ca), operacia (post del get) a nazov cert
    @type = type
    @operation = operation
    @param = param
    @date = date
    @status = status
    @uuid = SecureRandom.hex(10) 
  end
  
  #ruby ma svoju to_hash metodu ale s tou mi nefungovalo uuid
  def to_hash
  Hash["type" => @type, "operation" => @operation, "param" => @param, "date" => @date, "status" => @status, "uuid" => @uuid]
  end
end
#****************************


get '/' do #nepodstatne
  logger.info('hello')
  'Hello world!'
end

get "/features" do #foreman wants to know - hardcoded
  logger.info('listing features')	        
  '["logs","puppetca"]'
end

get "/version" do #nepodstatne
  logger.info('listing version')
  '{"version":"1.14.0-develop","modules":{"logs":"1.14.0", "puppet":"1.14.0"}}' #nezaklada sa na pravde
end

get "/ping" do #na normalnej proxy ping je undefined aj ked foreman sa to obcas pyta? (aspon vo logs to je vidno ze sa pyta..)
  logger.info('ping')
  'hello' 
end

get "/hashtest" do
  t = Task.new("a","b","c","d","e")
  x = t.to_hash
  taskarray.push(x)
  "hello"
end

get "/logs/" do
  logger.info('listing logs')
  content_type :json 
  logger.to_json	
end

post "/posttest/:testval" do
  title = params[:testval]
  title
end

##################################WEBUI#######################################################

get '/webui' do 
  erb :webui
end

get '/downloadtasks' do 
  if File.file?("/tmp/test.yml")
    time = Time.now.strftime('%Y_%m_%d_%H%M%S')
    send_file "/tmp/test.yml", :filename => "tasklist"+time+".yaml", :type => 'Application/octet-stream'
  else 
    erb :error
  end
end

get '/deletetasks' do
  if File.file?("/tmp/test.yml")
    File.delete("/tmp/test.yml") #zatial aby nemazalo pravy subor
    erb :success
  else 
    erb :error
  end
end

get '/listtasks' do #display UNSAVED list
  erb :something #y u no work
end

get '/savetasks' do
  File.open("/tmp/test.yml","w") do |file|
    taskarray.each do |task|
      t = task 
      file.write task.to_yaml
    end
  end
  erb :success
end

get '/deleteuuid' do
  erb :deleteuuid
end

post '/deletetaskuuid' do 
  u = params[:uuid]
  taskarray.delete_if { |h| h["uuid"] == u }
  redirect '/webui'
end

'''
get /deletesingletask do #delete task by uuid..bude potrebovat dialog
  erb :todo
end

get /inserttask do #manually insert a task? formular? 
  erb :todo
end

get /deletealltasks do #delete all unsaved tasks
  erb :todo
end
'''

###############################PUPPETCA#####################################################

get "/puppet/ca" do #list of all puppet certificates
  logger.info('Failed to list certificates')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca","get", nil, time , "none")
  x = t.to_hash
  taskarray.push(x)
  "Failed to list certificates"
end

get "/puppet/ca/autosign" do #list of all puppet autosign entires
  logger.info('Failed to list puppet autosign entries')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign","get", nil, time , "none")
  x = t.to_hash
  taskarray.push(x)
  "Failed to list puppet autosign entries"
end

post "/puppet/ca/autosign/:certname" do #Add certname to Puppet autosign
  arr = params[:certname]
  logger.info('Failed to add certname to Puppet autosign')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign/"+arr,"post", arr, time , "none")
  x = t.to_hash
  taskarray.push(x)
  "Failed to add certname to Puppet autosign"
end

delete "/puppet/ca/autosign/:certname" do #Remove certname from Puppet autosign	
  arr = params[:certname]
  logger.info('Failed to delete certname from Puppet autosign')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign/"+arr,"delete", arr, time , "none")
  x = t.to_hash
  taskarray.push(x)
  "Failed to delete certname from Puppet autosign"
end

post "/puppet/ca/:certname" do #Sign pending certificate request
  arr = params[:certname]
  logger.info('Failed to sign certname')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/"+arr,"post", arr, time , "none")
  x = t.to_hash
  taskarray.push(x)
  "Failed to sign certname"
end

delete "/puppetca/:certname" do #Remove (clean) and revoke a certificate
  arr = params[:certname]
  logger.info('Failed to delete certname')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/"+arr,"delete", arr, time , "none")
  x = t.to_hash
  taskarray.push(x)
  "Failed to delete certname"
end

require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/namespace'
require 'sinatra/contrib/all'
require 'yaml'

#env['rack.errors'] = '/home/barbora/fake-proxy/sinatra/app.error.log' #nope
set :bind, '0.0.0.0'
enable :logging #works
#set :logger #nope
require 'logger'
logger = Logger.new('/home/barbora/fake-proxy/sinatra/app.error.log')
#tasks = Logger.new('/home/barbora/fake-proxy/sinatra/app.tasks.log') 
arr = Array.new   
#class Proxy < Sinatra::Base #ak z toho urobim triedu tak sa zapne ale nic neodpoveda, modul mozno? 
require './puppet.rb'
register Puppet

#subor = YAML::load_file('/tmp/test.yml')

#****************Class Task
class Operation
  include Enumerable
  def each
    yield "get"
    yield "post"
    yield "delete"
  end
end

class Status #na get postt etc? na status? 
  include Enumerable
  def each
    yield "."
    #yield 
    #yield 
  end
end

class Task 
  def initialize(type, operation, params, date, status) #typ (napr /puppet/ca), operacia (post del get) a nazov cert
    @type = type
    @operation = operation
    @param = param 
    @date = date
    @status = status
  end
  
  def to_hash
  Hash["type" => @type, "operation" => @operation, "param" => @params, "date" => @date, "status" => @status]
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
  t = Task.new("a","b","c", "d", "e")
  x = t.to_hash
  File.open("/tmp/test.yml","a") do |file|
    file.write x.to_yaml
  end  
  t.to_hash.to_yaml
  #t.to_hash.to_yaml
end


get "/logs/" do
  logger.info('listing logs')
  content_type :json #doesnt work
  logger.to_json	
end

##################################WEBUI#######################################################

get '/webui' do #nepodstatne
  erb :webui
  # renders views/webui.erb
end

get '/downloadtasks' do 
  time = Time.now.strftime('%Y_%m_%d_%H%M%S')
  send_file "/tmp/test.yml", :filename => "tasklist"+time+".yaml", :type => 'Application/octet-stream'
end

get '/deletetasks' do
  File.delete("/tmp/test2.yml") #zatial aby nemazalo pravy subor
  redirect '/webui'
end

###############################PUPPETCA#####################################################

get "/puppet/ca" do #list of all puppet certificates
# /usr/bin/sudo -S /usr/local/bin/puppet cert --ssldir /etc/puppetlabs/puppet/ssl --list --all 
#z outputu 
# + "localhost" (SHA256) 58:63:9B:D7:6F:80:97:85:37:9D:C8:D4:D4:0A:BF:39:F4:12:68:AB:9D:F0:79:A1:9B:C2:C6:52:3D:97:7F:14
#resp s -H:
#+ "localhost"
#  (SHA256) 58:63:9B:D7:6F:80:97:85:37:9D:C8:D4:D4:0A:BF:39:F4:12:68:AB:9D:F0:79:A1:9B:C2:C6:52:3D:97:7F:14
#    Status: Signed
#    Expiration: 2021-11-09T23:18:24Z
#
#spravi:

#'{"localhost":{"state":"valid","fingerprint":"SHA256","serial":2,"not_before":"2016-11-09T23:18:24UTC","not_after":"2021-11-09T23:18:24UTC"},"Puppet":##{"serial":1,"not_before":"2016-11-09T23:18:23UTC","not_after":"2021-11-09T23:18:23UTC"}}' #odpoved zo smart-proxy 

# + no idea kde nasiel ten z puppetu 

  "Failed to list certificates"
#zaloguj event
  logger.info('Failed to list certificates')

#make a hash, store it
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca","get", nil, time , "none")
  x = t.to_hash
  File.open("/tmp/test.yml","a") do |file|
    file.write x.to_yaml
  end 
  #t.to_hash.to_yaml
  "Failed to list certificates"
end

get "/puppet/ca/autosign" do #list of all puppet autosign entires
  string = '["Failed to list puppet autosign entries"]' #nieco vypis..correctly co to si ulozis v metode nizsie
  logger.info('Failed to list puppet autosign entries')
  #content_type :json
  #Proxy::PuppetCa.autosign_list.to_json
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign","get", nil, time , "none")
  x = t.to_hash
  File.open("/tmp/test.yml","a") do |file|
    file.write x.to_yaml
  end 
  t.to_hash.to_yaml
end

post "/puppet/ca/autosign/:certname" do #Add certname to Puppet autosign
  arr << :certname
  "Failed to add certname to Puppet autosign"
  #zaloguj event
  logger.info('Failed to add certname to Puppet autosign')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign/:certname","post", arr, time , "none")
  x = t.to_hash
  File.open("/tmp/test.yml","a") do |file|
    file.write x.to_yaml
  end 
  #t.to_hash.to_yaml
end

delete "/puppet/ca/autosign/:certname" do #Remove certname from Puppet autosign	
  arr << :certname
  "Failed to delete certname from Puppet autosign"
  #zaloguj event
  logger.info('Failed to delete certname from Puppet autosign')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign/:cername","delete", arr, time , "none")
  x = t.to_hash
  File.open("/tmp/test.yml","a") do |file|
    file.write x.to_yaml
  end 
  #t.to_hash.to_yaml
end

post "/puppet/ca/:certname" do #Sign pending certificate request
  #content_type :json
  #certname = params[:certname]
  #Proxy::PuppetCa.sign(certname)

  arr << :certname
  "Failed to sign certname"
  #zaloguj event
  logger.info('Failed to sign certname')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/:cername","post", arr, time , "none")
  x = t.to_hash
  File.open("/tmp/test.yml","a") do |file|
    file.write x.to_yaml
  end 
  t.to_hash.to_yaml
end

delete "/puppetca/:certname" do #Remove (clean) and revoke a certificate
  #content_type :json
  #certname = params[:certname]
  #Proxy::PuppetCa.clean(certname)
  arr << :certname
  "Failed to delete certname"
  #zaloguj event
  logger.info('Failed to delete certname')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/:cername","delete", arr, time , "none")
  x = t.to_hash
  File.open("/tmp/test.yml","a") do |file|
    file.write x.to_yaml
  end 
  t.to_hash.to_yaml
end

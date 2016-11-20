require 'rubygems'
require 'bundler/setup'
require 'sinatra'
#require "./modules/puppet-proxy/puppet"
#require "./modules/puppetca"

enable :logging #works i guess

get '/' do
  'Hello world!'
  logger.info "loading data"
end

get "/features" do
  #status 404 	        
  string = '["logs"]'
  string.to_json #dont know behaviour of json :/
  #logger.info "displaying features" #if enabled it logs (stdout) but displays nothing
end

get "/version" do
  begin
  '{"version":"1.14.0-develop","modules":{"logs":"1.14.0"}}'
  end
end

############################PUPPET API UNTIL I FIGURE OUT HOW TO SEPARATE###################
post "/puppet/run" do #does not work
  'puppetrun'
end

get "/puppet/environments" do
  'env'
end

#get "/puppet/environments/:environment" do
#end

#get "/puppet/environments/:environment/classes" do
#end

#get "/puppet/environments/:environment/classes_and_errors" do
#end

###############################PUPPETCA#####################################################

get "/puppetca/?" do
  #content_type :json
  #Proxy::PuppetCa.list.to_json
end

get "/puppetca/autosign" do
  #content_type :json
  #Proxy::PuppetCa.autosign_list.to_json
end

post "/puppetca/autosign/:certname" do
  #content_type :json
  #certname = params[:certname]
  #Proxy::PuppetCa.autosign(certname)
end

delete "/puppetca/autosign/:certname" do
  #content_type :json
  #certname = params[:certname]
  #Proxy::PuppetCa.disable(certname)
end

post "/puppetca/:certname" do
  #content_type :json
  #certname = params[:certname]
  #Proxy::PuppetCa.sign(certname)
end

delete "/puppetca/:certname" do
  #content_type :json
  #certname = params[:certname]
  #Proxy::PuppetCa.clean(certname)
end

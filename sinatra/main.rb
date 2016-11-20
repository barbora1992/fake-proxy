require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/namespace'
require 'sinatra/contrib/all'

enable :logging #works i guess

#class Proxy < Sinatra::Base #ak z toho urobim triedu tak sa zapne ale nic neodpoveda
  #register Puppet

get '/' do
  'Hello world!'
  #logger.info "loading data"
end

get "/features" do
  #status 404 	        
  string = '["logs"]'
  string.to_json #len test
  #logger.info "displaying features" #if enabled it logs (stdout) but displays nothing
end

get "/version" do
  begin
  '{"version":"1.14.0-develop","modules":{"logs":"1.14.0"}}'
  end
end


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

#end

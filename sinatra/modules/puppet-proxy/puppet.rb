#class Proxy::Puppet::Api < ::Sinatra::Base
#extend Proxy::Puppet::DependencyInjection
#helpers ::Proxy::Helpers


#inject_attr :class_retriever_impl, :class_retriever
#inject_attr :environment_retriever_impl, :environment_retriever
#inject_attr :puppet_runner_impl, :puppet_runner

post "/run" do
  'puppetrun'
end

get "/environments" do
'env'
end

#get "/environments/:environment" do
#end

#get "/environments/:environment/classes" do
#end

#get "/environments/:environment/classes_and_errors" do
#end

#end

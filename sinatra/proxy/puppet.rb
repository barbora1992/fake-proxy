
module Puppet
  def self.registered(app)

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


end
register Puppet



module Puppet
  def self.registered(app)

    app.post "/puppet/run" do #does not work
      'puppetrun'
    end

    app.get "/puppet/environments" do
      'env'
    end

#get "/puppet/environments/:environment" do
#end

#get "/puppet/environments/:environment/classes" do
#end

#get "/puppet/environments/:environment/classes_and_errors" do
#end


  end
end


require 'rest-client'
require 'yaml'

class Task 
  def initialize(action, method, parameters, date, status, uuid) #action (whole /puppet/ca/:cert), method (post del get) a parameters :cert
    @action = action
    @method = method
    @parameters = parameters
    @date = date
    @status = status
    @uuid = uuid
  end
 
  attr_accessor :action, :method, :parameters, :date, :status, :uuid  
 
  def to_hash
    Hash["action" => @action, "method" => @method, "parameters" => @parameters, "date" => @date, "status" => @status, "uuid" => @uuid]
  end

  #def to_yaml #- either serialize to yaml or make makeshift hashes
  #  x = self.to_hash
  #  x.to_yaml
  #end

  def send_to_proxy(address) 
    op = self.action
    if self.method == "get" 
      response = RestClient::Request.execute(:method => :get, :url => address + op, :timeout => 3600)
      elsif self.method == "post"
        response = RestClient::Request.execute(:method => :post, :url => address + op, :timeout => 3600)
      elsif self.method == "delete"
       response = RestClient::Request.execute(:method => :delete, :url => address + op, :timeout => 3600)
    end
  end
end


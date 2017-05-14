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
 
  def send_to_proxy(address) 
    op = self.action
    if self.method == "GET" 
      response = RestClient::Request.execute(:method => :get, :url => address + op, :timeout => 3600)
      elsif self.method == "POST"
        response = RestClient::Request.execute(:method => :post, :url => address + op, :timeout => 3600)
      elsif self.method == "DELETE"
       response = RestClient::Request.execute(:method => :delete, :url => address + op, :timeout => 3600)
    end
  end
end


require 'yaml'

class Task 
  def initialize(action, method, parameters) #action (whole /puppet/ca/:cert), method (post del get) a parameters :cert
    @action = action
    @method = method
    @parameters = parameters
    @date = Time.now.strftime('%Y%m%d%H%M%S%L')
    @uuid = SecureRandom.hex(10) 
  end
 
  attr_accessor :action, :method, :parameters, :date, :uuid  

end

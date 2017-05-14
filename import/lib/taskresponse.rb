require 'yaml'

class TaskResponse
  def initialize(response, query, parameters, uuid, status, method)
    @response = response
    @query = query
    @parameters = parameters
    @uuid = uuid
    @status = status
    @method = method
  end

  attr_accessor :response, :query, :parameters, :uuid, :status, :method   
end

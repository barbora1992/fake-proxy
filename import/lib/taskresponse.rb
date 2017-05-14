require 'yaml'

class TaskResponse
  def initialize(response, query, parameters, uuid, method)
    @response = response
    @query = query
    @parameters = parameters
    @uuid = uuid
    @method = method
  end

  attr_accessor :response, :query, :parameters, :uuid, :status, :method   
end

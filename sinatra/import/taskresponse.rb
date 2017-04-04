require 'yaml'

class TaskResponse
  def initialize(response, query, uuid, status, method)
    @response = response
    @query = query
    @uuid = uuid
    @status = status
    @method = method
  end

  attr_accessor :response, :query, :uuid, :status, :method   
end

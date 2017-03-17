require 'yaml'

class TaskResponse
  def initialize(response, uuid)
    @response = response
    @uuid = uuid
  end

  attr_accessor :response, :uuid   
end

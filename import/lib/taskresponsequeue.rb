require 'yaml'

class TaskResponseQueue
  include Enumerable

  def initialize
    @queue = Array.new
  end

  def enqueue(task)
    @queue.push task
  end
  
  def each(&block)
    @queue.each(&block)
  end

  def to_yaml
    @queue.to_yaml
  end		

end

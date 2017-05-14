require 'yaml'

class TaskQueue
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

end

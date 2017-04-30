require 'yaml'

class TaskResponseQueue
  include Enumerable

  def initialize
    @queue = Array.new
  end

  def enqueue(task)
    @queue.push task
  end

  def delete_task_by_uuid(uuid)
    @queue.delete_if { |h| h.uuid == uuid }   
  end

  def clear
    @queue.clear
  end
  
  def each(&block)
    @queue.each(&block)
  end

  def to_yaml
    @queue.to_yaml
  end

  def find(uuid)
    @queue.detect { |h| h.uuid == uuid } 
  end

  def find_by_query_and_method(query, method)
    @queue.detect { |h| h.query == query && h.method == method && h.status != "expired"} 
  end

end

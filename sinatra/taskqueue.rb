require 'yaml'

class TaskQueue
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
  
  def mark_tasks_saved
    @queue.each do |task|  
    task.status = "saved" 
    end
  end  

  def set_finished(uuid)
    @queue.select { |h| h.uuid == uuid }.each{ |h| h.status = "finished" }
  end

  def delete_finished
    @queue.keep_if { |x| x.status != "finished" }
  end

  def task_exists(uuid)
    @queue.any? { |h| h.uuid == uuid }
  end

  def find_by_query_and_method(query, method)
    @queue.detect { |h| h.action == query && h.method == method && h.status != "expired"} 
  end

end

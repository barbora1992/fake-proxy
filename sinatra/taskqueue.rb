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

end

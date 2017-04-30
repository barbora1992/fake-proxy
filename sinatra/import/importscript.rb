require 'yaml'
require 'securerandom'
require 'optparse'
require 'ostruct'
require 'rest-client'
require 'pry'
require_relative "task"
require_relative "taskqueue"
require_relative "taskresponse"
require_relative "taskresponsequeue"

@buffer = TaskQueue.new #why do i have to make global variable here, and not in main? 
@responses = TaskResponseQueue.new

ARGV << '-h' if ARGV.empty?

def load_tasks(filename)
  if File.file?(filename)
    items = Array.new
    items = YAML.load_file(filename)
    items.each do |item|
      tmp = Task.new(item.action, item.method, item.parameters, item.date, item.status, item.uuid)
      #x = tmp.to_hash
      @buffer.enqueue(tmp)
    end
  else 
    abort("file does not exist")
  end
end

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-a', '--action ACTION', 'Action you want to take: send, list') { |o| options.action = o }
  opt.on('-i', '--input-file INPUTFILE', 'The input file') { |o| options.input_file = o }
  opt.on('-o', '--output-file OUTPUTFILE', 'The output file') { |o| options.output_file = o }
  opt.on('-p', '--proxy-address PROXYADDRESS', 'Address of the proxy you want to use') { |o| options.proxy_address = o } 
end.parse!

load_tasks(options.input_file)

if options.action == "send" 
  puts "sending all tasks"
  @buffer.each do |task|  
    response = task.send_to_proxy(options.proxy_address)
    puts response.body
    tmp = TaskResponse.new(response.body, task.action, task.uuid, "answered", task.method)
    @responses.enqueue(tmp)
  end
  file = File.new(options.output_file, 'w')
  file.write @responses.to_yaml
  file.close
  #puts @responses.to_yaml
  else options.action == "list"  
    puts "listing the tasks:" 
    puts @buffer.to_yaml
end





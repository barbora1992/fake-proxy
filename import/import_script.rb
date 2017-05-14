#!/usr/bin/env ruby

require 'yaml'
require 'securerandom'
require 'optparse'
require 'ostruct'
require 'rest-client'
require 'pry'

require "./lib/task.rb"
require "./lib/taskqueue.rb"
require "./lib/taskresponse.rb"
require "./lib/taskresponsequeue.rb"

@task_buffer = TaskQueue.new 
@response_buffer = TaskResponseQueue.new

ARGV << '-h' if ARGV.empty?

def load_tasks(filename)
  if File.file?(filename)
    items = Array.new
    items = YAML.load_file(filename)
    items.each do |item|
      tmp = Task.new(item.action, item.method, item.parameters, item.date, item.status, item.uuid)
      @task_buffer.enqueue(tmp)
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
  @task_buffer.each do |task| 
    begin 
      response = task.send_to_proxy(options.proxy_address)
      puts "Task UUID: " + task.uuid + ' was sent'
      tmp = TaskResponse.new(response.body, task.action, task.parameters, task.uuid, "answered", task.method)
      @response_buffer.enqueue(tmp)
    rescue => e
      puts "Task UUID: " + task.uuid + ": An error occured - please make sure that the proxy address is correct and the proxy has correct modules enabled" 
      exit
    end
  end
  file = File.new(options.output_file, 'w')
  file.write @response_buffer.to_yaml
  file.close
  puts "Tasks from " + options.input_file + ' were sent to ' + options.proxy_address + ' and the responses were saved in ' + options.output_file 
else options.action == "list"  
  puts "listing the tasks:" 
  @task_buffer.each do |task| 
    puts "Task UUID: " + task.uuid +  ' Method: ' + task.method.ljust(6) + ' Action: ' + task.action
  end
end





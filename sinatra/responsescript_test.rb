require_relative "import/task"
require_relative "import/taskqueue"
require_relative "import/taskresponsequeue"
require_relative "import/taskresponse"
require 'yaml'
require 'securerandom'
require 'optparse'
require 'ostruct'
require 'rest-client'
require 'pry'


@responses = TaskResponseQueue.new
filename = "import/responses.yaml"
if File.file?(filename)
  items = Array.new
  puts filename
  items = YAML.load_file(filename)
  
  #binding.pry
  #items.each do |item|
  #  tmp = TaskResponse.new(item.response, item.uuid)
    
   # @responses.enqueue(tmp)
  #end
  "hello"
else 
    abort("file does not exist")
end

#puts @responses.to_yaml

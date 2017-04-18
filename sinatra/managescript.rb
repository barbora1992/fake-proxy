require 'optparse'
require 'ostruct'
require 'rest-client'
require 'pry'
require 'yaml'


options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-a', '--action ACTION', 'Action you want to take: download (the task list), upload (responses from smart proxy)') { |o| options.action = o }
  opt.on('-f', '--file-name FILENAME', 'Name of the input/output file, accorting to the sellected action') { |o| options.file = o }
  opt.on('-p', '--proxy-address PROXYADDRESS', 'Address of the proxy you want to use') { |o| options.proxy_address = o }
end.parse!

if options.action == "download" 
  data = RestClient::Request.execute(:method => :get, :url => options.proxy_address + '/file', :timeout => 3600)
  file = File.new(options.file, 'w')
  file.write data
  file.close
end

if options.action == "upload" 
  file = File.new(options.file, 'r')
  response = RestClient::Request.execute(:method => :post, :url => options.proxy_address + '/responses', :payload => {:file => file})
end


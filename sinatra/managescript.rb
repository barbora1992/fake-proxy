require 'optparse'
require 'ostruct'
require 'rest-client'
require 'pry'
require 'yaml'

ARGV << '-h' if ARGV.empty?

options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-a', '--action ACTION', 'Action you want to take: download (the task list), upload (responses from smart proxy)') { |o| options.action = o }
  opt.on('-f', '--file-name FILENAME', 'Name of the input/output file, accorting to the sellected action') { |o| options.file = o }
  opt.on('-p', '--proxy-address PROXYADDRESS', 'Address of the proxy you want to use') { |o| options.proxy_address = o }
  #opt.on_tail("-h", "--help", "Show this message") do
  #      puts opt
  #      exit
  #    end
end.parse!



if options.action == "download" 
  data = RestClient::Request.execute(:method => :get, :url => options.proxy_address + '/file', :timeout => 3600)
  file = File.new(options.file, 'w')
  file.write data
  file.close
  puts 'Tasks were exported into ' + options.file
end

if options.action == "upload" 
  file = File.new(options.file, 'r')
  response = RestClient::Request.execute(:method => :post, :url => options.proxy_address + '/responses', :payload => {:file => file})
  puts 'Responses from ' + options.file + ' were uploaded to ' + options.proxy_address 
end


require 'optparse'
require 'ostruct'
require 'rest-client'
require 'pry'
require 'yaml'


options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-a', '--action ACTION', 'Action you want to take: download') { |o| options.action = o }
  opt.on('-f', '--file-name FILENAME', 'Name of the output file') { |o| options.output_file = o }
  opt.on('-p', '--proxy-address PROXYADDRESS', 'Address of the proxy you want to use') { |o| options.proxy_address = o }
end.parse!

if options.action == "download" 
  File.open(options.output_file, 'w') {|f|
    block = proc { |response|
      response.read_body do |chunk|
        puts "Working on response" 
        f.write chunk
      end
    }
    RestClient::Request.new(method: :get, url: options.proxy_address + '/file', block_response: block).execute
}
end

require 'yaml'
require 'securerandom'
require 'optparse'
require 'ostruct'
require 'rest-client'

@taskarray = Array.new #JUST FOR NOW!!!
@items = Array.new 

class Task  
  def initialize(type, operation, param, date, status, uuid) #typ (napr /puppet/ca), operacia (post del get) a nazov cert
    @type = type
    @operation = operation
    @param = param
    @date = date #ak budeme zdielat class task, tak date sa nesmie vytvarat v konstruktore (ako napr uuid) - jedine zeby overload constructors? to sa v ruby tusim neda
    @status = status
    @uuid = uuid
  end

  attr_accessor :uuid, :operation, :param
  
  #ruby ma svoju to_hash metodu ale s tou mi nefungovalo uuid
  def to_hash
    Hash["type" => @type, "operation" => @operation, "param" => @param, "date" => @date, "status" => @status, "uuid" => @uuid]
  end
end

def load(filename)
  if File.file?(filename)
    @items = YAML.load_file(filename) #apparently this is already array of no-name hashes. treba to spracovat do Task objektov? imho nie ale ak ano tak: 
    @items.each do |item|
    tmp = Task.new(item["type"],item["operation"],item["param"],item["date"],item["status"], item["uuid"])
    x = tmp.to_hash
    @taskarray.push(x)
    end
  #puts @taskarray.inspect 
  end
end

def sendToProxy(address, task) #posiela len SINGLE msg - kvoli tomu aby sa dala len vybrat jedna message, v sendAll sa preiteruje array a zavola send na vsetko

    require 'pry'
    binding.pry
  op = task["operation"]
  if task["type"] == "get" 
    response = RestClient.get address + op, task["param"] #params? :certname atd {params: {id: 50, \'foo\' => \'bar\'}}
    elseif task["type"] == "post"
      response = RestClient.post address + op
    elseif task["type"] == "delete"
     response = RestClient.delete address + op
  end
  #predpokladam ze si chceme zapisat response do suboru ktory by sme potom mohli vratit - mozno by bolo dobre mat response ako parameter v Task class? alebo mi napada este mat nejaky array of pairs <Task, Response> ? 
#also for now si pamatame celu response

end


#TODO:read documentation for this, najma option dependencies
options = OpenStruct.new
OptionParser.new do |opt|
  opt.on('-a', '--action LASTNAME', 'Action you want to take: send, sendbyuuid, list') { |o| options.action = o }
  opt.on('-f', '--input-file INPUTFILE', 'The input file') { |o| options.input_file = o }
  opt.on('-p', '--proxy-address PROXYADDRESS', 'Address of the proxy you want to use') { |o| options.proxy_address = o }
  opt.on('-u', '--uuid UUID', 'UUID of the task') { |o| options.uuid = o }
end.parse!

load(options.input_file)

if options.action == "send" 
  puts "task send" 
  item = Task.new("get", "/puppet/ca", nil, "20170308114623221", "new", "test") 
  #@taskarray.each do |item|
  sendToProxy(options.proxy_address, item)
  #end	
  

  elsif options.action == "sendbyuuid"  #HELP
    puts "task sendbyuuid"  

    tmp = @taskarray.detect {|x| x["uuid"] == options.uuid}

    #puts @taskarray[1]["uuid"]
    #tmp = @taskarray[1]
    #puts tmp.to_yaml
    #puts options.uuid
    #puts @taskarray.to_yaml
    #puts tmp.inspect
    sendToProxy(options.proxy_address, tmp)

    '''
    for i in 0..@taskarray.length
      if @taskarray[i]["uuid"] == options.uuid
        tmp = taskarray[i] 
      end
    end
    puts tmp
   '''

  elsif options.action == "list"  #works
    #load(options.input_file)
    puts "task list" 
    #puts @items
    puts @taskarray.to_yaml


end


get "/dhcp/?" do #does not work
  arr = '?'
  reply_or_create_task(arr, 'get', 'Dhcp')
end

get "/dhcp/:network" do
  arr = params[:network]
  reply_or_create_task(arr, 'get', 'Get DHCP network')
end

get "/dhcp/:network/unused_ip" do
end

get "/dhcp/:network/:record" do  # Deprecated, returns a single record
  reply_or_create_task(arr, 'get', 'Dhcp')
end

get "/dhcp/:network/ip/:ip_address" do # returns an array of records for an ip address
end

get "/dhcp/:network/mac/:mac_address" do  # returns a record for a mac address
end
 
post "/dhcp/:network" do  # create a new record in a network
  arr = params[:network]
  reply_or_create_task(arr, 'post', 'create a new record in a network')
end

delete "/dhcp/:network/:record" do  # deprecated, delete a record from a network
end

delete "/dhcp/:network/ip/:ip_address" do  # deletes all records for an ip address from a network
end

delete "/dhcp/:network/mac/:mac_address" do  # delete a record for a mac address from a network
end

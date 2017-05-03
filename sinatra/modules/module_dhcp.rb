get "/dhcp/?" do 
  reply_or_create_task('List DHCP subnets')
end

get "/dhcp/:network" do
  reply_or_create_task('Get DHCP network')
end

get "/dhcp/:network/unused_ip" do
  reply_or_create_task('Get unused IP')
end

get "/dhcp/:network/:record" do  
  reply_or_create_task('Deprecated, get DHCP network record')
end

get "/dhcp/:network/ip/:ip_address" do 
  reply_or_create_task('Get array of records for an ip address')
end

get "/dhcp/:network/mac/:mac_address" do 
  reply_or_create_task('Get record for a mac address')
end
 
post "/dhcp/:network" do  
  reply_or_create_task('Create a new record in a network')
end

delete "/dhcp/:network/:record" do 
  reply_or_create_task('Deprecated, delete a record from a network')
end

delete "/dhcp/:network/ip/:ip_address" do 
  reply_or_create_task('Delete all records for an ip address from a network')
end

delete "/dhcp/:network/mac/:mac_address" do  
  reply_or_create_task('Delete a record for a mac address from a network')
end

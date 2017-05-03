post "/tftp/fetch_boot_file" do
  reply_or_create_task('TFTP Fetch Boot File ')
end

post "/tftp/:variant/create_default" do
  reply_or_create_task('Create default config file')
end

get "/tftp/:variant/:mac" do 
  reply_or_create_task('Retrieve pxe config file')
end

post "/tftp/:variant/:mac" do 
  reply_or_create_task('Create config file for mac address')
end

delete "/tftp/:variant/:mac" do 
  reply_or_create_task('Delete config file for mac address')
end

post "/tftp/create_default" do
  reply_or_create_task('TFTP Create Default')
end

post "/tftp/:mac" do
  reply_or_create_task('TFTP Post MAC')
end

delete "/tftp/:mac" do
  reply_or_create_task('TFTP Delete MAC')
end

get "/tftp/serverName" do
  reply_or_create_task('TFTP Get Server Name')
end

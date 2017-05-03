get "/puppet/ca" do 
  reply_or_create_task('List Puppet CA certificates')
end

get "/puppet/ca/autosign" do
  reply_or_create_task('List Puppet CA autosign entries')
end

post "/puppet/ca/autosign/:certname" do
  reply_or_create_task('Add certname to Puppet autosign')
end

delete "/puppet/ca/autosign/:certname" do
  reply_or_create_task('Remove certname from Puppet autosign')
end

post "/puppet/ca/:certname" do 
  reply_or_create_task('Sign pending certificate request')
end

delete "/puppet/ca/:certname" do
  reply_or_create_task('Remove (clean) and revoke a certificate')
end


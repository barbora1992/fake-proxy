get "/puppet/ca" do 
  arr = nil
  reply_or_create_task(arr, 'get', 'List Puppet CA certificates')
end

get "/puppet/ca/autosign" do #list of all puppet autosign entires
  arr = nil
  reply_or_create_task(arr, 'get', 'List Puppet CA autosign')
end

########

post "/puppet/ca/autosign/:certname" do #Add certname to Puppet autosign
  arr = params[:certname]
  reply_or_create_task(arr, 'post', 'Add certname to Puppet autosign')
end

delete "/puppet/ca/autosign/:certname" do #Remove certname from Puppet autosign	
  arr = params[:certname]
  reply_or_create_task(arr, 'delete', 'Remove certname from Puppet autosign')
end

##########

post "/puppet/ca/:certname" do #Sign pending certificate request
  arr = params[:certname]
  reply_or_create_task(arr, 'post', 'Sign pending certificate request')
end

delete "/puppet/ca/:certname" do #Remove (clean) and revoke a certificate
  arr = params[:certname]
  reply_or_create_task(arr, 'delete', 'Remove (clean) and revoke a certificate')
end


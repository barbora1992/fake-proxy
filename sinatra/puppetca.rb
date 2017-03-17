get "/puppet/ca" do 
  logger.info('Failed to list certificates')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca","get", nil)
  taskarray.enqueue(t)
  "{}" #this works
end

get "/puppet/ca/autosign" do #list of all puppet autosign entires
  logger.info('Failed to list puppet autosign entries')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign","get", nil)
  taskarray.enqueue(t)
  "{}" #this works
end

post "/puppet/ca/autosign/:certname" do #Add certname to Puppet autosign
  arr = params[:certname]
  logger.info('Failed to add certname to Puppet autosign')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign/"+arr,"post", arr)
  taskarray.enqueue(t)
  content_type 'application/json' #thats how smart-proxy replies
  response.status = 404
end

delete "/puppet/ca/autosign/:certname" do #Remove certname from Puppet autosign	
  arr = params[:certname]
  logger.info('Failed to delete certname from Puppet autosign')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/autosign/"+arr,"delete", arr)
  taskarray.enqueue(t)
  content_type 'application/json'
  response.status = 404
end

post "/puppet/ca/:certname" do #Sign pending certificate request
  arr = params[:certname]
  logger.info('Failed to sign certname')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/"+arr,"post", arr)
  taskarray.enqueue(t)
  content_type 'application/json'
  response.status = 404
end

delete "/puppet/ca/:certname" do #Remove (clean) and revoke a certificate
  arr = params[:certname]
  logger.info('Failed to delete certname')
  time = Time.now.strftime('%Y%m%d%H%M%S%L')
  t = Task.new("/puppet/ca/"+arr,"delete", arr)
  taskarray.enqueue(t)
  content_type 'application/json'
  response.status = 404
end

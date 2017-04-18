post "/run" do
  arr = nil
  reply_or_create_task(arr, 'post', 'Run Puppet Proxy')
end

get "/environments" do
  arr = nill
  reply_or_create_task(arr, 'get', 'fail')
end

get "/environments/:environment" do
  arr = params[:environment]
  reply_or_create_task(arr, 'get', 'get proxy environment')

end

get "/environments/:environment/classes" do
  arr = params[:environment]
  reply_or_create_task(arr+'/classes', 'get', 'get proxy environment')
end

get "/environments/:environment/classes_and_errors" do
end


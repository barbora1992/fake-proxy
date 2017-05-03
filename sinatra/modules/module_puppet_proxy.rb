post "/puppet/run" do
  reply_or_create_task('Run Puppet Proxy')
end

get "/puppet/environments" do
  reply_or_create_task('List Puppet environments')
end

get "/puppet/environments/:environment" do
  reply_or_create_task('Show Puppet environment')
end

get "/puppet/environments/:environment/classes" do
  reply_or_create_task('Show Puppet classes for an environment')
end

get "/puppet/environments/:environment/classes_and_errors" do
  reply_or_create_task('Show Puppet classes and errors for an environment')
end


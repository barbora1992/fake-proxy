post "/dns/?" do
  reply_or_create_task('Create a new DNS record')
end

delete '/dns/:value/?:type?' do
  reply_or_create_task('Remove a DNS record')
end

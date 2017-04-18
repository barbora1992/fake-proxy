post "/dns/?" do
  arr = '?'
  reply_or_create_task(arr, 'post', 'create a new record in a network')
end

delete '/dns/:value/?:type?' do
end

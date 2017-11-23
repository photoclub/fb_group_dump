require 'koala'
require 'pry'

Koala.configure do |config|
  config.api_version = "v2.10"

  # Get new one at https://developers.facebook.com/tools/explorer/
  config.access_token = 'EAACEdEose0cBANv1VhNB6SrNHekq6TF5GoLmancBVUOHcCGUu2AZCbTob4agH9FrS5J3HpWKPcFGK78JqICaLp8ZA6EaXZAQCoiLexLjm0IfQClzq1r49FdUsnpduJJtqs5plyDUhPZCZBTDmaHrqjwWSbkHsId2HZCCs4lkZCZAr8VSSYqiLXjw37Lu9xcEUlsNQU3WA1Y6pwZDZD'

  # config.app_access_token = MY_APP_ACCESS_TOKEN
  # config.app_id = '251935475165380'
  # config.app_secret = MY_APP_SECRET
  # See Koala::Configuration for more options, including details on how to send requests through
  # your own proxy servers.
end

@graph = Koala::Facebook::API.new

group = @graph.get_object('252676155155732/feed')
file = File.open('dumps/курс_сутры_2017.txt', 'w')
# group = @graph.get_object('1641067156182554/feed')
# file = File.open('dumps/мир_сознания.txt', 'w')
posts = []
while(group.count > 0) do
  post_ids = group.map {|g| g['id']}
  full_posts = @graph.get_objects(post_ids)
  full_posts.each do |id, post|
    next unless post['link'] || post['message']
    posts << post
  end
  group = group.next_page
end

p 'Total: ', posts.count
# binding.pry

posts.reverse.each do |post|
  # if post['message']['почитать'].present?
  #   binding.pry
  # end
  file.write "#{post['updated_time']}\n"
  file.write "#{post['message']}\n" if post['message']
  file.write "<<#{post['story']}>>\n" if post['story']
  file.write "#{post['link']}\n" if post['link']
  comments = @graph.get_object("#{post['id']}/comments", fields: ['from{name}', 'message', 'comments'])
  file.write "\nКомментарии: \n" if comments.count > 0
  comments.each do |comment|
    file.write  '    ' + "#{comment['from']['name']}:\n"
    file.write  '        ' + "#{comment['message'].gsub("\n", "\n        ")}\n"
    next unless comment['comments']
    comment['comments']['data'].each do |sub_comment|
      file.write  '          ' + "#{sub_comment['from']['name']}:\n"
      file.write  '              ' + "#{sub_comment['message'].gsub("\n", "\n              ")}\n"
    end
  end
  file.write "-------------------------------------------------------------------\n\n"
  STDOUT << '.'
end
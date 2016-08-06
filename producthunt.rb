require 'hunting_season' # product hunt api
require 'csv' # write to CSV

def initialize_api
  puts "Enter your Developer Token:"
  dev_token = gets.chomp
  ProductHunt::Client.new(dev_token)
end

def request_domain
  puts "Enter a product URL, ie: http://generator.persistiq.com"
  gets.chomp
end

def get_post(client, product)
  client.all_posts("search[url]" => product)[0] # return first posted project with this URL
end

# hack that works but does not intelligently iterate through pages
def get_voters(post, voters = [], voters_raw = [])
  page_1 = post.votes(per_page: 50, order: 'asc')
  page_2 = post.votes(per_page: 50, order: 'asc', newer: page_1.last['id'])
  page_3 = post.votes(per_page: 50, order: 'asc', newer: page_2.last['id'])
  page_4 = post.votes(per_page: 50, order: 'asc', newer: page_3.last['id']) unless page_3.count < 50
  page_5 = post.votes(per_page: 50, order: 'asc', newer: page_4.last['id']) if page_4 && page_4.count == 50
  page_6 = post.votes(per_page: 50, order: 'asc', newer: page_5.last['id']) if page_5 && page_5.count == 50
  page_7 = post.votes(per_page: 50, order: 'asc', newer: page_6.last['id']) if page_6 && page_6.count == 50

  voters_raw << page_1
  voters_raw << page_2
  voters_raw << page_3 if page_3
  voters_raw << page_4 if page_4
  voters_raw << page_5 if page_5
  voters_raw << page_6 if page_6
  voters_raw << page_7 if page_7

  voters << voters_raw.flatten.uniq.map {|v| v['user']['twitter_username']}
  voters.flatten.uniq # remove dupes if hard-coded pagination goes too far
end

############
# GAMEPLAY #
############

client = initialize_api
product = request_domain
post = get_post(client, product)
voters = get_voters(post)

output = voters.each_slice(1).map {|x| p x} # split users into rows
File.open("#{post['name'].downcase}_voters.csv", "w") {|f| f.write(output.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join(""))}

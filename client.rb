require 'hunting_season' # product hunt api
require 'csv' # write to CSV

class UpvoteDownloader

  def initialize
    puts "what's your product hunt developer token?"
    @client = ProductHunt::Client.new(gets.chomp)
    clear

    puts "enter a product hunt URL, ie 'https://www.producthunt.com/posts/fomo-3'"
    @slug = gets.chomp.split("/posts/")[1]
    clear
  end

  def clear
    system 'clear'
  end

  def run
    puts "looking for post..."
    post = @client.all_posts("search[slug]" => @slug)[0]

    abort "post with slug '#{@slug}' not found, please try again." if post.nil?
    puts "found post..."

    get_and_show_voters(post)
  end

  def get_and_show_voters(post, voters = [])
    vote_count = post['votes_count']
    puts "processing #{vote_count} votes..."

    pages = (vote_count.to_f / 50).ceil
    pages.times do |page|
      voters << post.votes(per_page: 50, page: page+1, order: 'asc')
      voters.flatten!
      puts "finished #{voters.count} votes..."
    end

    output = voters.flatten.uniq.map {|v| v['user']['twitter_username']}.compact.each_slice(1).map {|x| p x} # split users into rows
    File.open("#{post['name'].downcase}_voters.csv", "w") {|f| f.write(output.inject([]) { |csv, row|  csv << CSV.generate_line(row) }.join(""))}
    clear

    puts "done!\nyour CSV export is in the same folder as this file.\npowered by: www.ryanckulp.com"
  end

end

# run
UpvoteDownloader.new.run

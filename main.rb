require 'set'
require 'nokogiri'
require 'open-uri'
require 'rss'

#code for making request and fetching rss data

url = 'https://edition.cnn.com/services/rss/' #get the url of the rss list
page = Nokogiri::HTML(URI.open(url))

#get the link tags with attribute type = "application/rss+xml"
links = page.xpath('//link[@type="application/rss+xml"]')

@map, counter = {}, 1 # map to store the rss and counter for indexing the hashmap
# map structure -> {key, [rssTitle, rssLink]}

links.each do |link|
	@map[counter] = [link['title'].to_str, link['href'].to_str]
	counter+=1
end

all_commands = Set.new(['--quit', '--hellp', '--unsub', '--sub', '--all', '--showFeed', '--show'])

def greetings
	# sleep 2
  puts '>>Welcome to RSS Reader 2023'
  puts '>>Type --help for help'
  puts '>>Type --quit to quit'
end

def start_rss_reader(all_commands)
	# sleep 1
  greetings
  input = gets.chomp
  while call_command(input, all_commands)
    input = gets.chomp
  end 
end


def show_not_subscribed_topic_list
	@user_subscriptions.sort # first sort so not get jumbled when user adds topic in unordered way
	@map.each do |key, value|
		if !Set.new(@user_subscriptions).include?key.to_s
			puts "#{key}. #{value[0]}" # value[0] -> rss topic
		end
	end
end

def subscribe_topic
	show_not_subscribed_topic_list
	topic_number = get_input('subscribe') # topic number token by user
	if !topic_number.match?(/[[:digit:]]/) || topic_number.to_i==0 || topic_number.to_i>@map.length
		puts ">>Invalid input"
		return
	end
	if @user_subscriptions.include?topic_number
		puts '>>Already subscribed!!'
		return
	end
	@user_subscriptions.append(topic_number)
	puts '>>Topic subscribed.'
end

def show_subscribed_topic_list
	if @user_subscriptions.length==0
		puts '>>No topic subscribed'
		return
	end
	@user_subscriptions.sort
	@user_subscriptions.each do |topic_number|
		puts "#{topic_number}. #{@map[topic_number.to_i][0]}"
	end
end

def unsubscribe_topic

	show_subscribed_topic_list
	topic_number = get_input('unsubscribe')

	if !topic_number.match?(/[[:digit:]]/) || topic_number.to_i==0 || topic_number.to_i>@map.length
		puts ">> Invalid input"
		return
	end

	if !@user_subscriptions.include?topic_number
		puts '>>Not yet subscribed'
		return
	end

	@user_subscriptions.delete(topic_number)
	puts '>>Topic unsubscribed'

end

#call the command

def call_command(input, all_commands)
  if input == '--help'
    get_help
  elsif input == '--sub'
		if @user_subscriptions.length==@map.length
			puts '>>No topic to subscribe.'
			return true
		end
    subscribe_topic # show the ones that the user has not subbed to
  elsif input == '--unsub'
		if @user_subscriptions.length==0
			puts '>>No topic to unsubscribe.'
			return true
		end
    unsubscribe_topic
  elsif input == '--all'
    show_all
	elsif input == '--showFeed'
		# sleep 1
		show_feed
	elsif input == '--show'
		show_subscribed_topic_list
	elsif input == '--showFeed'
		show_feed
  elsif input == '--quit'
		# sleep 0.5
		puts '>>Thanks for using RSS Reader'
		# sleep 1
    return false
  else
		# sleep 0.2
    puts "\n>>Incorrect command!! Please enter a valid command\n"
		# sleep 0.3
  end
	greetings
  return true
end

def get_input(text_value)
	puts ">>Enter the topic you want to #{text_value}"
	user_inputt = gets.chomp
	return user_inputt
end

@user_subscriptions = [] 



def show_feed
	if @user_subscriptions.length==0
		puts ">>Feed is Empty"
		return 
	end
	@user_subscriptions.each do |topic_id|
		puts "\n"
		puts ">>#{@map[topic_id.to_i][0]}\n"
		url = @map[topic_id.to_i][1]
		rss = RSS::Parser.parse(url)
		rss.items.each do |item|
			puts "  >>#{item.title}"
			puts "    >>#{item.description}"
			puts "    >>#{item.link}"
		end
	end
end

def get_help
	# sleep 2
  file = File.open('RssReader\help.txt')
  file_data = file.read
  puts file_data
  puts "\n"
end

def show_all()
	@map.each {|key, value| puts "#{key}. #{value[0]}"}
end

start_rss_reader(all_commands)

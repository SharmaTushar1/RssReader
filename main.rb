require 'set'

require 'nokogiri'

require 'open-uri'

require 'rss'

# code for making request and fetching rss data

url = 'https://edition.cnn.com/services/rss/' # get the url of the rss list

page = Nokogiri::HTML(URI.open(url))

# get the link tags with attribute type = "application/rss+xml" in the page

links = page.xpath('//link[@type="application/rss+xml"]')

@map, counter = {}, 1 # map to store the rss and counter for indexing the hashmap

# map structure -> {key, [rssTitle, rssLink]}



links.each do |link| # constructing hashmap
  @map[counter] = [link['title'].to_str, link['href'].to_str]

  counter += 1
end


# Create a  set so to store all the valid commands.


all_commands = Set.new(['--quit', '--hellp', '--unsub', '--sub', '--all', '--showFeed', '--show'])


def greetings
  # sleep 2 (Optional!! Can use sleep every now and then to make the output look more realistic.)

  puts '>>Welcome to RSS Reader 2023'

  puts '>>Type --help for help'

  puts '>>Type --quit to quit'
end

def start_rss_reader(all_commands)

  greetings

  input = gets.chomp

  input = gets.chomp while call_command(input)
end

def show_not_subscribed_topic_list
  @user_subscriptions.sort # first sort so not get jumbled when user adds topic in unordered way

  @map.each do |key, value|
    next if Set.new(@user_subscriptions).include? key.to_s # avoid values user has already subscribed.

    puts "#{key}. #{value[0]}" # value[0] -> rss topic

  end
end

def subscribe_topic
  show_not_subscribed_topic_list

  topic_number = get_input('subscribe') # topic number token by user

  if !topic_number.match?(/[[:digit:]]/) || topic_number.to_i.zero? || topic_number.to_i>@map.length

    puts '>>Invalid input'

    return

  end

  if @user_subscriptions.include? topic_number

    puts '>>Already subscribed!!'

    return

  end

  @user_subscriptions.append(topic_number)

  puts '>>Topic subscribed.'
end

def show_subscribed_topic_list
  if @user_subscriptions.empty?

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

  unless topic_number.match?(/[[:digit:]]/) || topic_number.to_i.zero? || topic_number.to_i > @map.length

    puts '>> Invalid input'

    return

  end

  unless @user_subscriptions.include? topic_number

    puts '>>Not yet subscribed'

    return

  end

  @user_subscriptions.delete(topic_number)

  puts '>>Topic unsubscribed'
end

# call the command

def call_command(input)
  case input
  when '--help'

    print_help

  when '--sub'

    if @user_subscriptions.length == @map.length

      puts '>>No topic to subscribe.'

      return true

    end

    subscribe_topic # show the ones that the user has not subbed to

  when '--unsub'

    if @user_subscriptions.empty?

      puts '>>No topic to unsubscribe.'

      return true

    end

    unsubscribe_topic

  when '--all'

    show_all

  when '--showFeed'

    # sleep 1

    show_feed

  when '--show'

    show_subscribed_topic_list

  when '--quit'

    puts '>>Thanks for using RSS Reader'

    return false

  else

    puts "\n>>Incorrect command!! Please enter a valid command\n"

  end

  greetings

  true
end

def get_input(text_value)
  puts ">>Enter the topic you want to #{text_value}"

  gets.chomp # return user input
end

@user_subscriptions = []

def show_feed
  if @user_subscriptions.empty?
    puts '>>Feed is Empty'
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

def print_help
  file = File.open('help.txt')

  file_data = file.read

  puts file_data

  puts "\n"
end

def show_all
  @map.each { |key, value| puts "#{key}. #{value[0]}" }
end


start_rss_reader(all_commands)

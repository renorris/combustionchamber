# HELLO THERE

require 'discordrb'

require_relative 'lib/request_handlers/event_processor'
require_relative 'lib/factories/vatsim_data_factory'
require_relative 'lib/tools/max_db'

SERVER_WHITELIST = File.read('server_whitelist.txt').split("\n").map! { |id| id.to_i }
puts "Whitelisted servers: #{SERVER_WHITELIST}"

VATSIM_DATA_FACTORY = VatsimDataFactory.new

MAX_DATABASE = MaxDatabase.new("lib/txt/max.txt")

HELP_TEXT = File.read('lib/txt/help.txt')

bot = Discordrb::Bot.new token: File.read('token.txt')

bot.ready do
  bot.watching = "people on vatsim"
  puts "Bot started"
end

bot.message(start_with: ';') do |event|

  event_processor = EventProcessor.new(event)
  event_processor.process

end

bot.run

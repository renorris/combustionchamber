require 'discordrb'

require_relative 'lib/factories/metar_factory'
require_relative 'lib/factories/vatsim_data_factory'
require_relative 'lib/factories/airport_diagram_factory'
require_relative 'lib/factories/max_factory'
require_relative 'lib/request_handlers/ping'

@help = File.read('lib/help.txt')
@metar_factory = MetarFactory.new
@vatsim_data_factory = VatsimDataFactory.new
@airport_diagram_factory = AirportDiagramFactory.new
@max_factory = MaxFactory.new

bot = Discordrb::Bot.new token: File.read('token.txt')

bot.ready do
  bot.watching = "people on vatsim"
  puts "Bot started"
end

bot.message(channel_types: [:server], start_with: ';') do |event|

  command = event.content.split(';', 2)[1].split(' ')[0]
  params = event.content.split(';', 2)[1].split(' ')[1..-1]

  message = case command
  when 'ping'
    @ping_handler = PingHandler.new
    @ping_handler.get_ping
  end

end

bot.message(start_with: ';ping') do |event|
  event.respond 'Pong!'
end

bot.message(start_with: ';metar') do |event|
  event.channel.start_typing
  icao = event.content.split(' ')[1].upcase

  metar = @metar_factory.get_metar(icao)

  if metar
    # Send normal result
    event.channel.send_embed() do |embed|
      embed.title = icao
      embed.description = "```\n" + metar + "\n```"
      embed.add_field(name: "Decoded", value: @metar_factory.get_decoded_metar(icao))
    end
  else
    # Send error result
    event.respond "Couldn't find a METAR for #{icao}"
  end
end

bot.message(start_with: ';atis') do |event|
  event.channel.start_typing
  icao = event.content.split(' ')[1].upcase

  atis = @vatsim_data_factory.get_atis(icao)

  if atis
    # Send normal result
    event.channel.send_embed() do |embed|
      embed.title = icao
      embed.description = "```\n" + atis + "\n```"
    end
  else
    # Send error result
    event.respond "Couldn't find an ATIS for #{icao}"
  end
end

bot.message(start_with: ';deps') do |event|
  event.channel.start_typing
  icao = event.content.split(' ')[1].upcase

  deps = @vatsim_data_factory.get_departures(icao)

  if deps

    # Generate list of aircraft with markdown links to vatstats
    aircraft_list = ''
    deps.each { |aircraft| aircraft_list += "[#{aircraft[:callsign]}](https://vatstats.net/flights/?callsign=#{aircraft[:callsign]})\n" }

    # Send normal result
    event.channel.send_embed() do |embed|
      embed.title = "#{icao} Departures"
      embed.add_field(name: 'Aircraft', value: aircraft_list)
    end
  else
    # Send error result
    event.respond "Couldn't find any departures out of #{icao}"
  end
end

bot.message(start_with: ';arrs') do |event|
  event.channel.start_typing
  icao = event.content.split(' ')[1].upcase

  arrs = @vatsim_data_factory.get_arrivals(icao)

  if arrs

    # Generate list of aircraft with markdown links to vatstats
    aircraft_list = ''
    arrs.each { |aircraft| aircraft_list += "[#{aircraft[:callsign]}](https://vatstats.net/flights/?callsign=#{aircraft[:callsign]})\n" }

    # Send normal result
    event.channel.send_embed() do |embed|
      embed.title = "#{icao} Arrivals"
      embed.add_field(name: 'Aircraft', value: aircraft_list)
    end
  else
    # Send error result
    event.respond "Couldn't find any arrivals into #{icao}"
  end
end

bot.message(start_with: ';diagram') do |event|
  event.channel.start_typing
  icao = event.content.split(' ')[1].upcase

  url = @airport_diagram_factory.get_diagram(icao)

  event.channel.send_embed() do |embed|
    embed.title = "#{icao} Airport Diagram"
    embed.url = url
  end
end

bot.message(start_with: ';help') do |event|
  event.respond "```\n" + @help + "\n```"
end

bot.message(start_with: ';max') do |event|
  event.respond @max_factory.get_image
end

bot.run
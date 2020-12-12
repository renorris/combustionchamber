require_relative '../factories/vatsim_data_factory'
require_relative 'embed_template'
require_relative 'response'

class VatsimDataHandler

  def initialize
    @response = Response.new
  end

  def get_atis(icao_codes)

    icao_codes.each do |icao|
      icao = icao.upcase

      atis = VATSIM_DATA_FACTORY.get_atis(icao)

      if atis
        embed = EmbedTemplate.new
        embed.title = "#{icao} ATIS"
        embed.description = "```\n" + atis + "\n```"
        @response.push_embed(embed)
      else
        # Send error result
        @response.push_text_message "#{icao} ATIS is not online"
      end
    end

    @response
  end

  def get_arrivals(icao_codes)

    icao_codes.each do |icao|
      icao = icao.upcase

      arrs = VATSIM_DATA_FACTORY.get_arrivals(icao)

      if arrs

        # Generate list of aircraft with markdown links to vatstats
        aircraft_list = ''
        arrs.each { |aircraft| aircraft_list += "**#{aircraft[:callsign]}** from #{aircraft[:dep_airport]}\n" }

        embed = EmbedTemplate.new
        embed.title = "#{icao} Arrivals"
        embed.add_field('Aircraft', aircraft_list)

        @response.push_embed embed
      else
        # Send error result
        @response.push_text_message "#{icao} does not have any filed arrivals"
      end
    end

    @response
  end

  def get_departures(icao_codes)

    icao_codes.each do |icao|
      icao = icao.upcase

      deps = VATSIM_DATA_FACTORY.get_departures(icao)

      if deps

        # Generate list of aircraft with markdown links to vatstats
        aircraft_list = ''
        deps.each { |aircraft| aircraft_list += "**#{aircraft[:callsign]}** to #{aircraft[:arr_airport]}\n" }

        embed = EmbedTemplate.new
        embed.title = "#{icao} Departures"
        embed.add_field('Aircraft', aircraft_list)

        @response.push_embed embed
      else
        # Send error result
        @response.push_text_message "#{icao} does not have any filed departures"
      end
    end

    @response
  end
end
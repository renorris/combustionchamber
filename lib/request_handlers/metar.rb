require_relative 'response'
require_relative '../factories/metar_factory'
require_relative 'embed_template'

class MetarHandler

  def initialize
    @response = Response.new
    @metar_factory = MetarFactory.new
  end

  def get_metar(icao_codes)

    # Truncate through each parameter, which
    # in this case are all airport icaos
    icao_codes.each do |icao|
      icao = icao.upcase

      metar = @metar_factory.get_metar(icao)

      if metar

        # Make a new embed template
        embed = EmbedTemplate.new
        embed.title = "#{icao} METAR"
        embed.description = "```\n" + metar + "\n```"
        embed.add_field('Decoded', @metar_factory.get_decoded_metar(icao))

        @response.push_embed(embed)

      else
        @response.push_text_message "No METAR available for #{icao}"
      end
    end

    @response
  end
end
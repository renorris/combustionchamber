require_relative 'response'
require_relative '../factories/airport_diagram_factory'
require_relative 'embed_template'

class AirportDiagramHandler

  def initialize
    @response = Response.new
    @airport_diagram_factory = AirportDiagramFactory.new
  end

  def get_diagram(icao_codes)

    # Truncate through each parameter, which
    # in this case are all airport icaos
    icao_codes.each do |icao|
      icao = icao.upcase

      url = @airport_diagram_factory.get_diagram(icao)

      embed = EmbedTemplate.new
      embed.title = "#{icao} Airport Diagram"
      embed.url = url

      @response.push_embed embed
    end

    @response
  end
end
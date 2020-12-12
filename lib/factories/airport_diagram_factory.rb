require 'net/http'

class AirportDiagramFactory

  def get_diagram(icao)
    icao = icao.upcase
    "https://flightaware.com/resources/airport/#{icao}/APD/AIRPORT+DIAGRAM/pdf"
  end
end
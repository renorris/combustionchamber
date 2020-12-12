require 'net/http'

class MetarFactory

  def get_metar(icao)
    icao = icao.upcase

    uri = URI("https://tgftp.nws.noaa.gov/data/observations/metar/stations/#{icao}.TXT")
    res = Net::HTTP.get_response(uri)

    if successful_response? res
      data = res.body
      data.split("\n")[1]
    else
      false
    end
  end

  def get_decoded_metar(icao)
    icao = icao.upcase

    uri = URI("https://tgftp.nws.noaa.gov/data/observations/metar/decoded/#{icao}.TXT")
    res = Net::HTTP.get_response(uri)

    decoded_metar = res.body

    if successful_response? res
      decoded_metar
    else
      false
    end
  end

  private

  def successful_response?(res)
    if res.code == "200"
      true
    else
      false
    end
  end

end
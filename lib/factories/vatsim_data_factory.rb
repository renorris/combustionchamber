require 'concurrent-ruby'

class VatsimDataFactory

  def initialize
    # Declare and reset instance vars
    reset()

    # Download initial data
    download_data()

    @time_last_downloaded = Time.now
  end

  def get_atis(icao)
    if should_download?
      download_data()
    end

    if @atises.key? icao
      @atises[icao]
    else
      false
    end
  end

  def get_departures(icao)
    if should_download?
      download_data()
    end

    if @departures.key?(icao)
      @departures[icao]
    else
      false
    end
  end

  def get_arrivals(icao)
    if should_download?
      download_data()
    end

    if @arrivals.key?(icao)
      @arrivals[icao]
    else
      false
    end
  end

  private

  def should_download?
    if Time.now - @time_last_downloaded > 120
      @time_last_downloaded = Time.now
      true
    else
      false
    end
  end

  def download_data

    # Reset previous data
    reset()

    # Download data and put all into @all_clients
    tracker = ''
    uri = URI('http://cluster.data.vatsim.net/vatsim-data.txt')
    puts "Downloading vatsim data..."
    cluster_data = Net::HTTP.get(uri)
    cluster_data.each_line do |line|
      if line.start_with? ';'
        if tracker == 'clients'
          tracker = ''
        end
        next
      elsif line.start_with? '!CLIENTS:'
        tracker = 'clients'
      else
        if tracker == 'clients'
          @all_clients.push line.split(':')
        end
      end
    end

    puts "Processing vatsim data..."

    # parse out atis clients
    @all_clients.each do |client|
      if client[0].include? "_ATIS"
        icao = client[0].split('_')[0]
        atis_message = client[35]

        # Replace UTF-8 characters with newlines
        atis_message = atis_message.gsub(/[^[:print:]]/i, "").gsub('^', "\n")

        @atises[icao] = atis_message
      end
    end

    # Parse out departures and arrivals
    @all_clients.each do |client|
      callsign = client[0]
      dep_airport = client[11]
      arr_airport = client[13]

      if dep_airport != ''
        # Create array if it doesn't already exist
        if @departures[dep_airport].nil?
          @departures[dep_airport] = []
        end

        hash = {
            callsign: callsign,
            arr_airport: arr_airport
        }

        @departures[dep_airport].push hash
      end

      if arr_airport != ''
        # Create array if it doesn't already exist
        if @arrivals[arr_airport].nil?
          @arrivals[arr_airport] = []
        end

        hash = {
            callsign: callsign,
            dep_airport: dep_airport
        }

        @arrivals[arr_airport].push hash
      end
    end

    puts "Updated vatsim data. #{@departures.length} departures, #{@arrivals.length} arrivals, #{@atises.length} atises, #{@all_clients.length} total users"
  end

  def reset
    @atises = Concurrent::Hash.new
    @all_clients = Concurrent::Array.new
    @departures = Concurrent::Hash.new
    @arrivals = Concurrent::Hash.new
  end

end
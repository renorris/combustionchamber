require_relative 'response'

class PingHandler

  def initialize
    @response = Response.new
  end

  def ping
    @response.push_text_message "Pong!"
    @response
  end

end
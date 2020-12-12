require_relative '../factories/airport_diagram_factory'
require_relative '../factories/metar_factory'
require_relative '../factories/vatsim_data_factory'
require_relative 'ping'
require_relative 'metar'
require_relative 'response'
require_relative 'vatsim_data'
require_relative 'help'
require_relative 'airport_diagram'
require_relative 'tags'
require_relative 'poll'

class RequestDispatcher

  def dispatch(command, params, event)

    response = case command
               when 'ping'
                 ping_handler = PingHandler.new
                 ping_handler.ping()
               when 'metar', 'wx'
                 metar_handler = MetarHandler.new
                 metar_handler.get_metar(params)
               when 'atis'
                 atis_handler = VatsimDataHandler.new
                 atis_handler.get_atis(params)
               when 'arrs', 'arrivals'
                 arrs_handler = VatsimDataHandler.new
                 arrs_handler.get_arrivals(params)
               when 'deps', 'departures', 'depart'
                 deps_handler = VatsimDataHandler.new
                 deps_handler.get_departures(params)
               when 'help'
                 help_handler = HelpHandler.new
                 help_handler.get_help
               when 'max', 'sexyman'
                 max_handler = MaxHandler.new
                 max_handler.process(params)
               when 'diagram', 'apd'
                 airport_diagram_handler = AirportDiagramHandler.new
                 airport_diagram_handler.get_diagram(params)
               when 't', 'tag'
                 tag_handler = TagHandler.new(event)
                 tag_handler.process(params)
               when 'poll'
                 poll_handler = PollHandler.new(event)
                 poll_handler.get_poll(params)
               else
                 response = Response.new
                 response.push_text_message "Command `#{command}` not found!"
                 response
               end
    response
  end

end
require_relative 'response'

class HelpHandler

  def initialize
    @response = Response.new
  end

  def get_help
    @response.push_text_message "```\n" + HELP_TEXT + "\n```"
    @response
  end
end
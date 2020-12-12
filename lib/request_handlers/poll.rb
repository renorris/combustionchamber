require_relative 'response'

class PollHandler

  def initialize(event)
    @event = event
    @response = Response.new
  end

  def get_poll(params)

    poll_title = params.join(' ')

    embed = EmbedTemplate.new
    embed.title = "Poll"
    embed.description = "```\n" + poll_title + "\n```"
    embed.add_field('By', get_display_name(@event.author.id))
    embed.add_reaction('✅')
    embed.add_reaction('❌')
    @response.push_embed embed

    @response.delete_command_message

    @response
  end

  private

  def get_display_name(user_id)
    user_id = user_id.to_i

    display_name = 'unknown user'

    @event.server.members.each do |member|
      if member.id == user_id
        display_name = member.display_name
      end
    end

    display_name
  end
end
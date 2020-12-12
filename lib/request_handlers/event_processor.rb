require_relative 'dispatcher'

class EventProcessor

  def initialize(event)
    @event = event
  end

  def process

    # Return early if the request does
    # not originate from a whitelisted server
    unless is_whitelisted?
      return
    end

    # Parse command and command parameters
    command = @event.content.split(';', 2)[1].split(' ')[0]
    params = @event.content.split(';', 2)[1].split(' ')[1..-1]

    @event.channel.start_typing

    # Define dispatcher
    dispatcher = RequestDispatcher.new

    # Get response object from dispatcher
    @response = dispatcher.dispatch(command, params, @event)

    if @response.should_delete_command_message?
      @event.message.delete
    end

    # Send each plaintext message in response
    @event.channel.send_multiple(@response.text_messages)

    # Build each embed object from each embed template in response and send to channel
    build_and_send_embeds
  end

  private

  def is_whitelisted?
    # Check if request is from a whitelisted server
    if SERVER_WHITELIST.include? @event.server.id
      true
    else
      puts "WARNING: Request '#{@event.content}' received from non-whitelisted server '#{@event.server.name}' (#{@event.server.id})"
      false
    end
  end

  def build_and_send_embeds
    @response.embeds.each do |embed_template|
      embed_message = @event.channel.send_embed do |embed|
        embed.title = embed_template.title
        embed.description = embed_template.description
        embed.url = embed_template.url

        embed_template.fields.each do |field|
          embed.add_field(name: field[:name], value: field[:value], inline: field[:inline])
        end

      end

      embed_template.reactions.each { |reaction| embed_message.create_reaction(reaction) }
    end
  end
end
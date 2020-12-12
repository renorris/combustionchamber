class Response

  def initialize
    @messages = []
    @embeds = []
    @delete_command_message = false
  end

  def push_embed(embed_template)
    @embeds.push embed_template
  end

  def push_text_message(message_text)
    @messages.push message_text
  end

  def text_messages
    @messages
  end

  def embeds
    @embeds
  end

  def delete_command_message
    @delete_command_message = true
  end

  def should_delete_command_message?
    @delete_command_message
  end

end
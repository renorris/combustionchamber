require_relative 'response'
require_relative 'database_manager'

class TagHandler

  def initialize(event)
    @event = event
    @response = Response.new
    @database = DatabaseManager.new(@event.server.id)
  end

  def process(params)
    @params = params

    tag_command = @params[0]

    if tag_command.nil?
      @response.push_text_message "You must specify a tag"
      return @response
    end

    case tag_command
    when 'info'
      get_tag_info
    when 'edit'
      edit_tag
    when 'delete'
      delete_tag
    when 'list'
      list_tags
    else
      get_set_tag
    end

    @response
  end

  private

  def get_set_tag
    tag_name = @params[0]

    if tag_exists?(tag_name)
      # Return tag text because it already exists

      tag = @database.db.execute("SELECT * FROM tags WHERE name = ?", [tag_name])[0][2]
      @response.push_text_message tag
    else
      # Create a new tag because it doesn't exist

      tag_text = @params[1..-1].join(' ')

      unless text_valid?(tag_text)
        @response.push_text_message 'You must specify a value for the tag'
        return @response
      end

      @database.db.execute("INSERT INTO tags (name, owner, value) VALUES (?,?,?)", [tag_name, @event.author.id, tag_text])
      @response.push_text_message "Created tag `#{tag_name}`"
    end
  end

  def get_tag_info
    tag_name = @params[1]

    unless text_valid?(tag_name)
      @response.push_text_message 'Error: tag text invalid'
      return @response
    end

    unless tag_exists?(tag_name)
      @response.push_text_message "Tag `#{tag_name}` not found"
    end

    tag_data = @database.db.execute("SELECT * FROM tags WHERE name = ?", [tag_name])[0]

    embed = EmbedTemplate.new
    embed.title = "Tag **#{tag_name}**"
    embed.add_field('Author', get_display_name(tag_data[1]))

    @response.push_embed(embed)
  end

  def edit_tag
    tag_name = @params[1]

    unless text_valid?(tag_name)
      @response.push_text_message 'You must specify a tag to edit'
      return @response
    end

    unless tag_exists?(tag_name)
      @response.push_text_message "Tag #{tag_name} does not exist"
      return @response
    end

    if owner?(tag_name, @event.author.id)
      tag_text = @params[2..-1].join(' ')

      unless text_valid?(tag_text)
        @response.push_text_message 'You must specify a new value for the tag'
        return @response
      end

      @database.db.execute("UPDATE tags SET value = ? WHERE name = ?", [tag_text, tag_name])
      @response.push_text_message "Successfully edited `#{tag_name}`"
    else
      @response.push_text_message "Failed to edit: you do not own `#{tag_name}`"
    end
  end

  def delete_tag
    tag_name = @params[1]

    unless text_valid?(tag_name)
      @response.push_text_message 'You must specify a tag to delete'
      return @response
    end

    unless tag_exists?(tag_name)
      @response.push_text_message "Tag #{tag_name} does not exist"
      return @response
    end

    if owner?(tag_name, @event.author.id)

      @database.db.execute("DELETE FROM tags WHERE name = ?", [tag_name])
      @response.push_text_message "Successfully deleted `#{tag_name}`"
    else
      @response.push_text_message "Failed to edit: you do not own #{tag_name}"
    end
  end

  def list_tags
    all_tags = @database.db.execute("SELECT * FROM tags")
    all_names = all_tags.map { |tag| tag[0]}

    @response.push_text_message "```\n" + "All tags:\n\n" + all_names.join(' ') + "\n```"
  end

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

  def owner?(tag_name, user_id)
    user_id = user_id.to_i

    if @database.db.execute( "SELECT * FROM tags WHERE name = ?", [tag_name] )[0][1].to_i == user_id || user_id == 353023343110389762
      true
    else
      false
    end
  end

  def tag_exists?(tag_name)
    if @database.db.execute("SELECT * FROM tags WHERE name = ?", [tag_name]) == []
      false
    else
      true
    end
  end

  def text_valid?(text)
    if text.nil? || text == ''
      false
    else
      true
    end
  end
end
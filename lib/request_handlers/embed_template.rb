# Stupid discordrb doesn't let you make a portable Embed object, so here we go

class EmbedTemplate

  def initialize
    @description = ''
    @fields = []
    @title = ''
    @url = ''
    @reactions = []
  end

  def description=(description)
    @description = description
  end

  def description
    @description
  end

  def add_field(name, value, inline = false)
    field = {
        name: name,
        value: value,
        inline: inline
    }
    @fields.push field
  end

  def fields
    @fields
  end

  def title=(title)
    @title = title
  end

  def title
    @title
  end

  def url=(url)
    @url = url
  end

  def url
    @url
  end

  def add_reaction(reaction)
    @reactions.push reaction
  end

  def reactions
    @reactions
  end
end
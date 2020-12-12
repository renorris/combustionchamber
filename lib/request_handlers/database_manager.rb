require 'sqlite3'

class DatabaseManager

  def initialize(server_id)
    @server_id = server_id
    @db = SQLite3::Database.new "db/#{server_id}.db"

    # Create tags table if not exists
    @db.execute "CREATE TABLE IF NOT EXISTS tags ( `name` BLOB NOT NULL, `owner` INT NOT NULL, `value` BLOB NOT NULL)"
  end

  def db
    @db
  end

end
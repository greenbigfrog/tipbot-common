struct TB::Data::TwitchChannel
  DB.mapping(
    id: Int32,
    name: String,
    created_at: Time
  )

  # Adds a new channel to join the next time
  def self.create(name : String, coin : Coin)
    TB::DATA.exec(<<-SQL, name, coin.id)
    INSERT INTO channels(name, coin) VALUES ($1, $2)
      ON CONFLICT DO NOTHING
    SQL
  end

  # Gets a Set of all channels
  def self.read
    TB::DATA.query_all("SELECT * FROM channels", as: self)
  end

  def self.read_names
    TB::DATA.query_all("SELECT name FROM channels", as: String)
  end

  def self.read_by_name(name : String)
    TB::DATA.query_one?("SELECT * FROM channels WHERE name = $1", name, as: self)
  end

  # Deletes a channel
  def self.delete(name : String, coin : Coin)
    TB::DATA.exec("DELETE FROM channels WHERE name = $1 AND coin = $2", name, coin.id)
  end
end

struct TB::Data::Discord::Guild
  DB.mapping(
    id: Int64,

    guild_id: Int64,
    coin: Int32,

    created_time: Time,

    prefix: String?,

    mention: Bool?,
    soak: Bool?,
    rain: Bool?,

    min_soak: BigDecimal?,
    min_soak_total: BigDecimal?,

    min_rain: BigDecimal?,
    min_rain_total: BigDecimal?,

    min_tip: BigDecimal?,
    min_lucky: BigDecimal?
  )

  def self.read_config_id(id : Int64, coin : Coin)
    TB::DATA.query_one("SELECT id FROM guilds WHERE guild_id = $1 AND coin = $2", id, coin.id, as: Int64)
  end

  def self.read_by_guild_id(guild : Int64)
    TB::DATA.query_all(<<-SQL, guild, as: self)
    SELECT guilds.id, guild_id, coin, created_time,
    prefix, mention,
    soak, rain,
    min_soak, min_soak_total,
    min_rain, min_rain_total,
    min_tip, min_lucky
    FROM guilds
    LEFT OUTER JOIN configs ON guilds.id = configs.id
    WHERE guild_id = $1
    SQL
  end

  def self.read_guild_id(id : Int64)
    TB::DATA.query_one("SELECT guild_id FROM guilds WHERE id = $1", id, as: Int64)
  end

  def self.new?(id : Int64, coin : Coin)
    TB::DATA.query_one?(<<-SQL, id, coin.id, as: Bool)
    INSERT INTO guilds(guild_id, coin)
    VALUES ($1, $2)
    ON CONFLICT ON CONSTRAINT guilds_guild_id_coin_key
    DO UPDATE SET coin = guilds.coin RETURNING (xmax = 0) AS inserted;
    SQL
  end

  def self.read_prefix(id : Int64, coin : Coin)
    TB::DATA.query_one?("SELECT prefix FROM guilds, configs WHERE guild_id = $1 AND coin = $2", id, coin.id, as: String?)
  end

  def self.read_config(id : Int64, coin : Coin, field : String) : Bool?
    TB::DATA.query_one?("SELECT #{field} FROM guilds, configs WHERE guild_id = $1 AND coin = $2", id, coin.id, as: Bool?)
  end

  def self.update_prefix(id : Int64, coin : Coin, prefix : String?)
    update_config(id, coin, "prefix", prefix)
  end

  def self.update_config(config_id : Int64, prefix : String?,
                         mention : Bool?, soak : Bool?, rain : Bool?,
                         min_soak : BigDecimal?, min_soak_total : BigDecimal?,
                         min_rain : BigDecimal?, min_rain_total : BigDecimal?,
                         min_tip : BigDecimal?, min_lucky : BigDecimal?)
    sql = <<-SQL
    INSERT INTO configs(id, prefix, mention, soak, rain,
                        min_soak, min_soak_total, min_rain, min_rain_total,
                        min_tip, min_lucky)
    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
    ON CONFLICT (id) DO
    UPDATE SET  prefix = COALESCE($2, configs.prefix),
                mention = COALESCE($3, configs.mention),
                soak = COALESCE($4, configs.soak),
                rain = COALESCE($5, configs.rain),
                min_soak = COALESCE($6, configs.min_soak),
                min_soak_total = COALESCE($7, configs.min_soak_total),
                min_rain = COALESCE($8, configs.min_rain),
                min_rain_total = COALESCE($9, configs.min_rain_total),
                min_tip = COALESCE($10, configs.min_tip),
                min_lucky = COALESCE($11, configs.min_lucky);
    SQL
    TB::DATA.exec(sql, config_id,
      prefix, mention, soak, rain,
      min_soak, min_soak_total, min_rain, min_rain_total,
      min_tip, min_lucky)
  end

  def self.read_decimal_config(id : Int64, coin : Coin, field : String) : BigDecimal?
    TB::DATA.query_one?("SELECT #{field} FROM guilds, configs WHERE guild_id = $1 AND coin = $2", id, coin.id, as: BigDecimal?)
  end
end

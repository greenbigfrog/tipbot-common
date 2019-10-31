struct TB::Data::Statistics
  DB.mapping(
    transaction_count: Int64?,
    transaction_sum: BigDecimal?,
    tip_sum: BigDecimal?,
    soak_sum: BigDecimal?,
    rain_sum: BigDecimal?,
    last_refresh: Time
  )

  TTL = 30.minutes

  def self.read
    stats = TB::DATA.query_one("SELECT * FROM statistics", as: Statistics)
    if stats.last_refresh < Time.utc_now - TTL
      update
      return read
    end
    stats
  end

  def self.update
    TB::DATA.exec("REFRESH MATERIALIZED VIEW statistics")
  end
end

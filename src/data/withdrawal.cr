struct TB::Data::Withdrawal
  DB.mapping(
    id: Int32,
    pending: Bool,
    coin: Int32,
    user_id: Int64,
    address: String,
    amount: BigDecimal,
    transaction: Int64,
    created_time: Time
  )

  def self.create(coin : Coin, user_id : Int32, address : String, amount : BigDecimal, transaction : Int32, db : DB::Connection = TB::DATA.connection)
    db.query_one("INSERT INTO withdrawals(coin, user_id, address, amount, transaction) VALUES ($1, $2, $3, $4, $5) RETURNING id", coin.id, user_id, address, amount, transaction, as: Int32)
  end

  def self.read(id : Int32)
    TB::DATA.query_one("SELECT * FROM withdrawals WHERE id = $1", id, as: self)
  end

  def self.read_pending_withdrawals(db : DB::Connection)
    db.query_all("SELECT * FROM withdrawals WHERE pending = true FOR UPDATE", as: self)
  end

  def self.update_pending(id : Int32, status : Bool, db : DB::Connection)
    db.exec("UPDATE withdrawals SET pending = $1 WHERE id = $2", status, id)
  end
end

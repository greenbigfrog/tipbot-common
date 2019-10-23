require "./enum"

struct TB::Data::Transaction
  DB.mapping(
    id: Int32,

    coin: Int32,

    # memo: TB::Data::TransactionMemo,

    amount: BigDecimal,

    account_id: Int32,

    address: String?,
    coin_transaction_id: String?,

    time: Time
  )

  # def self.read(id : Int64)
  #   TB::DATA.query_one?("SELECT * FROM transactions WHERE id = $1", id, as: self)
  # end

  def self.read_amount(id : Int32, db : DB::Connection)
    db.query_one?("SELECT amount FROM transactions WHERE id = $1", id, as: BigDecimal)
  end

  def self.update_fee(id : Int32, adjust_by : BigDecimal, db : DB::Connection)
    amount = read_amount(id, db).not_nil!
    new_amount = amount - adjust_by
    db.exec("UPDATE transactions SET amount = $1 WHERE id = $2", new_amount, id)
  end
end

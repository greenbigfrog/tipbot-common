enum TB::Data::DepositStatus
  NEW
  CREDITED
  NEVER
end

module DepositStatusConverter
  def self.from_rs(result : ::DB::ResultSet) : TB::Data::DepositStatus
    TB::Data::DepositStatus.parse(String.new(result.read(Slice(UInt8))))
  end
end

struct TB::Data::Deposit
  DB.mapping(
    txhash: String,
    coin: Int32,
    status: {
      type:      DepositStatus,
      converter: DepositStatusConverter,
    },
    account_id: Int32?,
    created_time: Time
  )

  def self.create(txhash : String, coin : Coin, status : DepositStatus, account_id : Int32? = nil)
    TB::DATA.exec(<<-SQL, txhash, coin.id, status, account_id)
  		INSERT INTO deposits (txhash, coin, status, account_id)
  		VALUES ($1, $2, $3, $4)
  		ON CONFLICT DO NOTHING
  		SQL
  end

  def self.read_new(db : DB::Connection)
    db.query_all("SELECT * FROM deposits WHERE status = 'NEW' FOR UPDATE", as: self)
  end

  def mark_never(db : DB::Connection)
    db.exec("UPDATE deposits SET status = 'NEVER' WHERE txhash = $1", @txhash)
  end

  def mark_never_with_account(account_id : Int32, db : DB::Connection)
    db.exec("UPDATE deposits SET status = 'NEVER', account_id = $2 WHERE txhash = $1", @txhash, account_id)
  end

  def mark_credited(account_id : Int32, db : DB::Connection)
    db.exec("UPDATE deposits SET status = 'CREDITED', account_id = $2 WHERE txhash = $1", @txhash, account_id)
  end
end

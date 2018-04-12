require 'sqlite3'

class Database
  def initialize()
    @db = SQLite3::Database.new("checking-system.db")
    @db.results_as_hash = true
  end

  def insert(cardId, userName, password)
    @db.execute("INSERT INTO credentials(card_id, username, password)
      VALUES(?, ?, ?)", cardId, userName, password)
  end

  def getByCardId(cardId)
    @db.get_first_row("SELECT * FROM credentials where card_id = ?", cardId)
  end

  def toggleState(cardId)
    credential = getByCardId(cardId)
    unless credential.nil?
      state = credential["state"]
      state = state == 1 ? 0 : 1
      @db.execute("UPDATE credentials set state = ?", state)
    end
  end
end

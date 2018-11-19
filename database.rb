require 'sqlite3'

class Database
  def initialize()
    @db = SQLite3::Database.new("checking-system.db")
    @db.results_as_hash = true
    @db.execute "CREATE TABLE IF NOT EXISTS credentials(
        card_id INTEGER PRIMARY KEY,
        username TEXT NOT NULL, 
        password TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    "

    @db.execute "CREATE TABLE IF NOT EXISTS logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_id INTEGER NOT NULL, 
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (card_id) REFERENCES credenetials (id) ON UPDATE CASCADE
      )
    "

    @db.execute "CREATE UNIQUE INDEX IF NOT EXISTS created_at_index ON logs(created_at);"
    @db.execute "CREATE UNIQUE INDEX IF NOT EXISTS card_id_index ON credentials(card_id);"
  end

  def insert(cardId, userName, password)
    @db.execute("REPLACE INTO credentials(card_id, username, password)
      VALUES(?, ?, ?)", cardId, userName, password)
  end

  def getByCardId(cardId)
    @db.get_first_row("SELECT * FROM credentials INDEXED BY card_id_index where card_id = ?", cardId)
  end

  def getLastLog(cardId)
    @db.get_first_row("SELECT * FROM logs INDEXED BY created_at_index where card_id = ? ORDER BY created_at DESC", cardId)
  end

  def countLogs(cardId)
    @db.get_first_row("SELECT COUNT(*) FROM logs where card_id = ?", cardId)
  end

  def insertLog(cardId)
    @db.execute("INSERT INTO logs(card_id) VALUES(?)", cardId)
  end
end

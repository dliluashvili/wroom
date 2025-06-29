require "db"
require "pg"

module WatchingRoom
  class Database
    @@db : DB::Database? = nil

    def self.connection
      @@db ||= DB.open("postgres://#{ENV["PG_USERNAME"]}:#{ENV["PG_PASSWORD"]}@localhost:#{ENV["PG_PORT"]}/#{ENV["PG_DB"]}")
    end

    def self.setup
      self.connection.exec "CREATE TABLE IF NOT EXISTS users (
        id VARCHAR(200) UNIQUE NOT NULL,
        email VARCHAR(200) UNIQUE NOT NULL,
        username VARCHAR(200) UNIQUE NOT NULL,
        fullname VARCHAR(200) NOT NULL,
        password VARCHAR(200) NOT NULL,
        created_at TIMESTAMP NOT NULL,
        updated_at TIMESTAMP NOT NULL
      )"

      self.connection.exec "CREATE TABLE IF NOT EXISTS sessions (
        session_id VARCHAR(200) UNIQUE NOT NULL,
        user_id VARCHAR(200) NOT NULL REFERENCES users(id),
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP NOT NULL
      )"

      self.connection.exec "CREATE TABLE IF NOT EXISTS rooms (
        id VARCHAR(200) UNIQUE NOT NULL,
        user_id VARCHAR(200) NOT NULL REFERENCES users(id),
        name VARCHAR(200) NOT NULL,
        language VARCHAR(100) NOT NULL,
        password VARCHAR(200) NULL,
        description TEXT NULL,
        is_private BOOLEAN NOT NULL,
        capacity INT NOT NULL,
        url VARCHAR(200) NOT NULL,
        created_at TIMESTAMP NOT NULL,
        updated_at TIMESTAMP NOT NULL
      )"

      self.connection.exec "CREATE TABLE IF NOT EXISTS room_users (
        room_id VARCHAR(200) NOT NULL REFERENCES rooms(id),
        user_id VARCHAR(200) NOT NULL REFERENCES users(id),
        is_owner BOOLEAN NOT NULL DEFAULT FALSE,
        created_at TIMESTAMP NOT NULL
      )"

      self.connection.exec "CREATE TABLE IF NOT EXISTS room_states (
        id SERIAL PRIMARY KEY,
        room_id VARCHAR(200) NOT NULL REFERENCES rooms(id),
        user_id VARCHAR(200) NOT NULL REFERENCES users(id),
        state VARCHAR(200) NOT NULL,
        video_current_time FLOAT NOT NULL,
        is_paused BOOLEAN NOT NULL DEFAULT FALSE,
        is_owner BOOLEAN NOT NULL DEFAULT FALSE,
        formatted_video_current_time VARCHAR(200) NOT NULL,
        send_time FLOAT NOT NULL,
        created_at TIMESTAMP NOT NULL,
        updated_at TIMESTAMP NOT NULL
      )"
    end
  end
end

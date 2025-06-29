require "../models/user"
require "../config/database"

module WatchingRoom
  class UserRepository
    def self.create(user : User)
      now = Time.utc
      user.created_at = now
      user.updated_at = now

      db = Database.connection
      db.query_one(
        "INSERT INTO users (id, email, username, fullname, password, created_at, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING id",
        user.id, user.email, user.username, user.fullname, user.password, now, now
      ) do |rs|
        user.id = rs.read(String)
      end
      user
    end

    def self.find_by_id(id : String) : User?
      db = Database.connection
      user = nil

      db.query("SELECT id, email, password, username, fullname, created_at FROM users WHERE id = $1 LIMIT 1", id) do |rs|
        rs.each do
          id = rs.read(String)
          email = rs.read(String)
          password = rs.read(String)
          username = rs.read(String)
          fullname = rs.read(String)
          created_at = rs.read(Time)

          user = User.new(
            id: id,
            email: email,
            password: password,
            username: username,
            fullname: fullname,
            created_at: created_at
          )
        end
      end

      user
    end

    def self.find_by_username(username : String) : User?
      db = Database.connection
      user = nil

      db.query("SELECT id, email, password, username, fullname, created_at FROM users WHERE username = $1 LIMIT 1", username) do |rs|
        rs.each do
          id = rs.read(String)
          email = rs.read(String)
          password = rs.read(String)
          username = rs.read(String)
          fullname = rs.read(String)
          created_at = rs.read(Time)

          user = User.new(
            id: id,
            email: email,
            password: password,
            username: username,
            fullname: fullname,
            created_at: created_at
          )
        end
      end

      user
    end
  end
end

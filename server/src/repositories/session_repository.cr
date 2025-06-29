module WatchingRoom
  class SessionRepository
    def self.create(session : Session)
      now = Time.utc
      session.created_at = now

      db = Database.connection
      db.query_one(
        "INSERT INTO sessions (session_id, user_id, expires_at, created_at)
         VALUES ($1, $2, $3, $4) RETURNING session_id",
        session.session_id, session.user_id, session.expires_at, now
      ) do |rs|
        session.session_id = rs.read(String)
      end
      session
    end

    def self.find_by_session_id(session_id : String)
      db = Database.connection
      db.query_one(
        "SELECT * FROM sessions WHERE session_id = $1",
        session_id
      ) do |rs|
        return WatchingRoom::Session.new(
          session_id: rs.read(String),
          user_id: rs.read(String),
          expires_at: rs.read(Time),
          created_at: rs.read(Time)
        )
      end
      nil
    end
  end
end

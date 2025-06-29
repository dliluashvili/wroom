module WatchingRoom
  class RoomRepository
    def self.create(room : Room)
      now = Time.utc

      db = Database.connection
      db.query_one(
        "INSERT INTO rooms (id, user_id, name, is_private, capacity, url, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING id",
        room.id, room.user_id, room.name, room.is_private, room.capacity, room.url, now, now
      ) do |rs|
        room.id = rs.read(String)
      end
      room
    end

    def self.find_by_user_id(user_id : String) : Room?
      db = Database.connection
      room = nil

      db.query("SELECT id, user_id, name, is_private, capacity, url, created_at FROM rooms WHERE user_id = $1 LIMIT 1", user_id) do |rs|
        rs.each do
          id = rs.read(String)
          user_id = rs.read(String)
          name = rs.read(String)
          is_private = rs.read(Bool)
          capacity = rs.read(Int32)
          url = rs.read(String)
          created_at = rs.read(Time)

          room = Room.new(
            id: id,
            user_id: user_id,
            name: name,
            is_private: is_private,
            capacity: capacity,
            url: url,
            created_at: created_at
          )
        end
      end

      room
    end

    def self.find_room_user(user_id : String, room_id : String) : RoomUser?
      db = Database.connection
      room_user = nil

      db.query("SELECT room_id, user_id, is_owner FROM room_users WHERE user_id = $1 and room_id = $2 LIMIT 1", user_id, room_id) do |rs|
        rs.each do
          room_id = rs.read(String)
          user_id = rs.read(String)
          is_owner = rs.read(Bool)

          room_user = RoomUser.new(
            room_id: room_id,
            user_id: user_id,
            is_owner: is_owner
          )
        end
      end

      room_user
    end

    def self.find_by_room_id(room_id : String) : Room?
      db = Database.connection
      room = nil

      db.query("SELECT id, user_id, name, is_private, capacity, url, created_at FROM rooms WHERE id = $1 LIMIT 1", room_id) do |rs|
        rs.each do
          id = rs.read(String)
          user_id = rs.read(String)
          name = rs.read(String)
          is_private = rs.read(Bool)
          capacity = rs.read(Int32)
          url = rs.read(String)
          created_at = rs.read(Time)

          room = Room.new(
            id: id,
            user_id: user_id,
            name: name,
            is_private: is_private,
            capacity: capacity,
            url: url,
            created_at: created_at
          )
        end
      end

      room
    end

    def self.join(user_id : String, room_id : String, is_owner : Bool) : String
      now = Time.utc
      db = Database.connection

      res = db.query("INSERT INTO room_users (room_id, user_id, is_owner, created_at) VALUES ($1, $2, $3, $4)", room_id, user_id, is_owner, now)

      room_id
    end

    def self.is_already_joined(user_id : String, room_id : String) : Bool
      db = Database.connection
      is_joined = false

      db.query("SELECT COUNT(*) FROM room_users WHERE room_id = $1 AND user_id = $2", room_id, user_id) do |rs|
        rs.each do
          count = rs.read(Int64)
          is_joined = count > 0
        end
      end

      is_joined
    end

    def self.find_available_rooms : Array(Room)
      db = Database.connection
      rooms = [] of Room

      db.query("SELECT id, user_id, name, is_private, capacity, url, created_at FROM rooms") do |rs|
        rs.each do
          id = rs.read(String)
          user_id = rs.read(String)
          name = rs.read(String)
          is_private = rs.read(Bool)
          capacity = rs.read(Int32)
          url = rs.read(String)
          created_at = rs.read(Time)

          room = Room.new(
            id: id,
            user_id: user_id,
            name: name,
            is_private: is_private,
            capacity: capacity,
            url: url,
            created_at: created_at
          )

          rooms << room
        end
      end

      rooms
    end
  end
end

module WatchingRoom
  class RoomStateRepository
    def self.create(roomState : RoomState)
      now = Time.utc

      db = Database.connection
      db.query_one(
        "INSERT INTO room_states (room_id, user_id, state, is_paused, is_owner, video_current_time, send_time, formatted_video_current_time, created_at, updated_at)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10) RETURNING id",
        roomState.room_id, roomState.user_id, roomState.state.to_s, roomState.is_paused, roomState.is_owner, roomState.video_current_time, roomState.send_time, roomState.formatted_video_current_time, now, now
      ) do |rs|
        roomState.id = rs.read(Int32)
      end
      roomState
    end

    def self.get_by_room_id(room_id : String) : Array(RoomState)
      db = Database.connection
      roomStates = Array(RoomState).new

      db.query("SELECT id, room_id, user_id, state, video_current_time, formatted_video_current_time, created_at FROM room_states WHERE room_id = $1", room_id) do |rs|
        rs.each do
          id = rs.read(Int32)
          room_id = rs.read(String)
          user_id = rs.read(String)
          state = rs.read(String)
          video_current_time = rs.read(Float64)
          send_time = rs.read(Float64)
          formatted_video_current_time = rs.read(String)
          created_at = rs.read(Time)

          roomState = RoomState.new(
            id: id,
            room_id: room_id,
            user_id: user_id,
            state: state,
            video_current_time: video_current_time,
            send_time: send_time,
            formatted_video_current_time: formatted_video_current_time,
            created_at: created_at
          )
          roomStates << roomState
        end
      end

      roomStates
    end

    def self.get_latest_by_room_id(room_id : String) : RoomState?
      db = Database.connection
      roomState = nil

      db.query("SELECT id, room_id, user_id, is_paused, is_owner, state, video_current_time, send_time, formatted_video_current_time, created_at FROM room_states WHERE room_id = $1 ORDER BY created_at DESC LIMIT 1", room_id) do |rs|
        rs.each do
          id = rs.read(Int32)
          room_id = rs.read(String)
          user_id = rs.read(String)
          is_paused = rs.read(Bool)
          is_owner = rs.read(Bool)
          state = MediaState.parse(rs.read(String))
          video_current_time = rs.read(Float64)
          send_time = rs.read(Float64)
          formatted_video_current_time = rs.read(String)
          created_at = rs.read(Time)

          roomState = RoomState.new(
            room_id: room_id,
            user_id: user_id,
            is_paused: is_paused,
            is_owner: is_owner,
            state: state,
            video_current_time: video_current_time,
            send_time: send_time,
            formatted_video_current_time: formatted_video_current_time,
            created_at: created_at
          )
        end
      end

      roomState
    end
  end
end

module HTTP
  class WebSocket
    property user_id : String? = nil
  end
end

module WatchingRoom
  class RoomPool
    @@room_pool : Hash(String, Set(HTTP::WebSocket)) = {} of String => Set(HTTP::WebSocket)

    @@user_sockets : Hash(String, Set(HTTP::WebSocket)) = {} of String => Set(HTTP::WebSocket)

    def self.add(socket : HTTP::WebSocket, user_id : String, room_id : String) : String
      socket.user_id = user_id

      @@room_pool[room_id] ||= Set(HTTP::WebSocket).new

      @@room_pool[room_id] << socket

      @@user_sockets[user_id] ||= Set(HTTP::WebSocket).new

      @@user_sockets[user_id] << socket

      room_id
    end

    def self.get_user_sockets(user_id : String) : Set(HTTP::WebSocket)
      @@user_sockets[user_id]? || Set(HTTP::WebSocket).new
    end

    def self.get_room_sockets(room_id : String) : Set(HTTP::WebSocket)
      @@room_pool[room_id]? || Set(HTTP::WebSocket).new
    end

    def self.remove_socket(socket : HTTP::WebSocket)
      if user_id = socket.user_id
        @@user_sockets[user_id]?.try(&.delete(socket))
      end

      @@room_pool.each_value do |room|
        room.delete(socket)
      end
    end
  end
end

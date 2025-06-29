require "kemal"
require "../dtos/create-room.dto"
require "../services/auth_service"

post "/rooms" do |env|
  currentUserId = env.get("currentUserId").as(String)

  createRoomDto = WatchingRoom::CreateRoomDto.from_json(env.request.body.not_nil!)

  room = WatchingRoom::RoomService.create(createRoomDto, currentUserId)

  env.response.content_type = "application/json"

  {success: true, room: room}.to_json
end

post "/rooms/join/:room_id" do |env|
  currentUserId = env.get("currentUserId").as(String)

  room_id = env.params.url["room_id"]

  room_id = WatchingRoom::RoomService.join(currentUserId, room_id)

  env.response.content_type = "application/json"

  {success: true, room_id: room_id}.to_json
end

get "/rooms/available" do |env|
  rooms = WatchingRoom::RoomService.find_available_rooms

  env.response.content_type = "application/json"

  {success: true, rooms: rooms}.to_json
end

get "/rooms/my" do |env|
  currentUserId = env.get("currentUserId").as(String)

  room = WatchingRoom::RoomService.find_by_user_id(currentUserId)

  env.response.content_type = "application/json"

  {success: true, room: room}.to_json
end

get "/rooms/:id" do |env|
  currentUserId = env.get("currentUserId").as(String)

  id = env.params.url["id"]

  room = WatchingRoom::RoomService.find_by_room_id(id)

  env.response.content_type = "application/json"

  {success: true, room: room}.to_json
end

ws "/socket/room/:room_id" do |socket, context|
  room_id = context.ws_route_lookup.params["room_id"]

  query_params = HTTP::Params.parse(context.request.query || "")

  session_id = query_params["session"]?

  room_id = context.params.url["room_id"]

  if session_id.nil? || session_id.empty?
    # Close the connection without sending any message
    socket.close(4001, "Authentication required")
    next
  end

  begin
    user = WatchingRoom::AuthService.get_current_user(session_id)

    if user.nil?
      socket.close(4002, "Invalid session")
      next
    end

    current_user_id = user.id

    if ENV["MAINTENANCE_MODE"]? == "true"
      socket.close(4005, "Server is in maintenance mode")
      next
    end

    socket.on_message do |message|
      socket_message = WatchingRoom::SocketMessage.from_json(message)

      case socket_message.type
      when WatchingRoom::SocketMessageType::MEDIA
        begin
          body = {
            current_user_id: current_user_id,
            room_id:         room_id,
            socket_message:  socket_message,
          }

          WatchingRoom::MediaMessageService.handle(body)
        rescue ex
          # Log the error but keep the connection alive
          print "Error processing MEDIA message: #{ex.message}\n#{ex.backtrace?.try &.join("\n")}"
        end
      when WatchingRoom::SocketMessageType::ROOM
        WatchingRoom::RoomPool.add(socket, current_user_id, room_id)

        print "\nuser_idd is adding: #{current_user_id}\n"
        room_state = WatchingRoom::RoomService.get_latest_state_by_room_id(room_id)

        video_current_time = 0.0
        is_paused = true

        if !room_state.nil?
          video_current_time = room_state.video_current_time
          is_paused = room_state.is_paused
        end

        socket.send({
          type:    WatchingRoom::SocketMessageType::ROOM,
          payload: {
            state:              WatchingRoom::MediaState::JOIN,
            video_current_time: video_current_time,
            is_paused:          is_paused,
          },
        }.to_json)
      else
        print "\nUnknown message type: #{socket_message.type}\n"
      end
    end

    # Handle connection close
    socket.on_close do |code, message|
      print "\nSocket closed: #{code} - #{message}\n"
      WatchingRoom::RoomPool.remove_socket(socket)
    end
  rescue ex
    print "\n Error!!!"
    socket.close(4000, "Server error: #{ex.message}")
  end
end

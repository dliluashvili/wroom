module WatchingRoom
  class MediaMessageService
    def self.create(createMediaMessageDto : CreateMediaMessageDto)
      mediaMessage = RoomState.new(
        room_id: createMediaMessageDto.room_id,
        user_id: createMediaMessageDto.user_id,
        is_paused: createMediaMessageDto.is_paused,
        is_owner: createMediaMessageDto.is_owner,
        state: createMediaMessageDto.state,
        video_current_time: createMediaMessageDto.video_current_time,
        send_time: createMediaMessageDto.send_time,
        formatted_video_current_time: createMediaMessageDto.formatedVideoTime
      )

      RoomStateRepository.create(mediaMessage)
    end

    def self.handle(body : NamedTuple)
      room_id = body[:room_id]
      user_id = body[:current_user_id]

      print body[:socket_message].payload.send_time

      room = RoomRepository.find_by_room_id(room_id)

      raise "Room not found" if room.nil?

      user_in_room = RoomRepository.find_room_user(user_id, room_id)

      raise "User not found in room" if user_in_room.nil?

      createMediaMessageDto = CreateMediaMessageDto.new(
        user_id: body[:current_user_id],
        room_id: body[:room_id],
        is_paused: body[:socket_message].payload.is_paused || false,
        is_owner: user_in_room.is_owner,
        state: body[:socket_message].payload.state,
        video_current_time: body[:socket_message].payload.video_current_time || 0.0,
        send_time: body[:socket_message].payload.send_time || 0.0,
        formatedVideoTime: body[:socket_message].payload.formatedVideoTime || ""
      )

      MediaMessageService.create(createMediaMessageDto)

      room_users_sockets = RoomPool.get_room_sockets(body[:room_id])

      room_users_sockets.each do |socket|
        next if socket.closed? || socket.user_id == body[:current_user_id]

        print "\nSending message to socket: #{socket.user_id}\n"

        socket.send({
          type:    SocketMessageType::MEDIA,
          payload: {
            state:              body[:socket_message].payload.state,
            is_paused:          body[:socket_message].payload.is_paused,
            video_current_time: body[:socket_message].payload.video_current_time,
            send_time:          body[:socket_message].payload.send_time,
            formatedVideoTime:  body[:socket_message].payload.formatedVideoTime,
          },
        }.to_json)
      end
    end
  end
end

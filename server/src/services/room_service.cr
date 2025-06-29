require "../repositories/room_repository"
require "../models/room"
require "../models/user"
require "../dtos/create-room.dto"
require "crypto/bcrypt/password"
require "uuid"

module WatchingRoom
  class RoomService
    def self.create(createRoomDto : CreateRoomDto, currentUserId : String) : Room
      room = Room.new(
        id: UUID.random.to_s,
        user_id: currentUserId,
        name: createRoomDto.name,
        is_private: createRoomDto.is_private,
        capacity: createRoomDto.capacity,
        url: createRoomDto.url
      )

      RoomRepository.create(room)
    end

    def self.find_by_user_id(currentUserId : String) : Room?
      RoomRepository.find_by_user_id(currentUserId)
    end

    def self.join(user_id : String, room_id : String) : String
      room = RoomRepository.find_by_room_id(room_id)

      raise "Room not found" if room.nil?

      is_owner = room.user_id == user_id

      is_already_joined = RoomRepository.is_already_joined(user_id, room_id)

      is_already_joined ? room_id : RoomRepository.join(user_id, room_id, is_owner)
    end

    def self.get_latest_state_by_room_id(room_id : String) : RoomState?
      RoomStateRepository.get_latest_by_room_id(room_id)
    end

    def self.find_by_room_id(id : String) : Room?
      RoomRepository.find_by_room_id(id)
    end

    def self.find_available_rooms : Array(Room)
      RoomRepository.find_available_rooms
    end
  end
end

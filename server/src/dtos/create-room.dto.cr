require "json"

module WatchingRoom
  class CreateRoomDto
    include JSON::Serializable

    property name : String
    property is_private : Bool
    property capacity : Int32
    property url : String
  end
end

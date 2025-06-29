module WatchingRoom
  class RoomUser
    include JSON::Serializable

    property room_id : String
    property user_id : String
    property is_owner : Bool
    property created_at : Time?
    property updated_at : Time?

    def initialize(@room_id : String, @user_id : String, @is_owner : Bool, @created_at : Time? = nil, @updated_at : Time? = nil)
    end
  end
end

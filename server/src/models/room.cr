module WatchingRoom
  class Room
    include JSON::Serializable

    property id : String
    property user_id : String
    property name : String
    property is_private : Bool
    property capacity : Int32
    property url : String
    property created_at : Time?
    property updated_at : Time?

    def initialize(@id : String, @user_id : String, @name : String, @is_private : Bool, @capacity : Int32, @url : String, @created_at : Time? = nil, @updated_at : Time? = nil)
    end
  end
end

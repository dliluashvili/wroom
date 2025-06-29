module WatchingRoom
  class RoomState
    include JSON::Serializable

    property id : Int32?
    property room_id : String
    property user_id : String
    property state : MediaState
    property is_paused : Bool
    property is_owner : Bool
    property video_current_time : Float64
    property send_time : Float64
    property formatted_video_current_time : String
    property created_at : Time?
    property updated_at : Time?

    def initialize(@room_id : String, @user_id : String, @state : MediaState, @is_paused : Bool, @is_owner : Bool, @video_current_time : Float64, @send_time : Float64, @formatted_video_current_time : String, @created_at : Time? = nil, @updated_at : Time? = nil)
    end
  end
end

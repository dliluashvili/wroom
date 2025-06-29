require "json"

module WatchingRoom
  class CreateMediaMessageDto
    include JSON::Serializable

    property user_id : String
    property room_id : String
    property state : MediaState
    property is_paused : Bool
    property is_owner : Bool
    property video_current_time : Float64
    property send_time : Float64
    property formatedVideoTime : String

    def initialize(@user_id : String, @room_id : String, @state : MediaState, @is_paused : Bool, @is_owner : Bool, @video_current_time : Float64, @send_time : Float64, @formatedVideoTime : String)
    end
  end
end

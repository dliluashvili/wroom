require "json"

module WatchingRoom
  enum MediaState
    PLAY
    PAUSE
    TIME_UPDATE
    JOIN

    def to_json(json : JSON::Builder)
      json.string(to_s)
    end

    def self.new(pull : JSON::PullParser)
      string = pull.read_string
      parse(string.upcase)
    end
  end

  enum SocketMessageType
    MEDIA
    ROOM

    def to_json(json : JSON::Builder)
      json.string(to_s)
    end

    def self.new(pull : JSON::PullParser)
      string = pull.read_string
      parse(string.upcase)
    end
  end

  class MediaPayload
    include JSON::Serializable

    property state : MediaState
    property is_paused : Bool?
    property video_current_time : Float64?
    property send_time : Float64?
    property formatedVideoTime : String?
  end

  class SocketMessage
    include JSON::Serializable

    property type : SocketMessageType
    property payload : MediaPayload
  end
end

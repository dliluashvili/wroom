module WatchingRoom
  class Session
    property session_id : String
    property user_id : String
    property expires_at : Time?
    property created_at : Time?

    def initialize(@session_id : String, @user_id : String, @expires_at : Time?, @created_at : Time? = nil)
    end
  end

  def expired?
    expires_at < Time.utc
  end
end

module WatchingRoom
  class User
    include JSON::Serializable

    property id : String
    property email : String
    property username : String
    property fullname : String
    property password : String
    property created_at : Time?
    property updated_at : Time?

    def initialize(@id : String, @email : String, @username : String, @fullname : String, @password : String, @created_at : Time? = nil, @updated_at : Time? = nil)
    end
  end
end

require "json"

module WatchingRoom
  class SignUpDto
    include JSON::Serializable

    property email : String
    property username : String
    property fullname : String
    property password : String
  end
end

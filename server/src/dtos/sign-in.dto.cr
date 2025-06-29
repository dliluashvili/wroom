require "json"

module WatchingRoom
  class SignInDto
    include JSON::Serializable

    property username : String
    property password : String
  end
end

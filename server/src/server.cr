require "./config/database"
require "./routes/**"
require "./services/**"
require "./repositories/**"
require "./models/**"
require "kemal"


module WatchingRoom
  Database.setup

  before_all do |env|
    # Add CORS headers
    env.response.headers.add("Access-Control-Allow-Origin", "*")
    env.response.headers.add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS")
    env.response.headers.add("Access-Control-Allow-Headers", "Content-Type, Authorization")
  end

  before_all do |env|
    # Define excluded paths (auth routes)
    excluded_paths = ["/auth/login", "/auth/register", "/auth/reset-password"]

    # Skip middleware for excluded paths
    next if excluded_paths.any? { |excluded| env.request.path.starts_with?(excluded) }

    # Get the Authorization header
    session_id = env.request.headers["Authorization"]?

    if session_id.nil? || session_id.empty?
      env.response.status_code = 401
      env.response.content_type = "application/json"
      next {success: false, message: "Unauthorized: No authorization provided"}.to_json
    end

    begin
      user = WatchingRoom::AuthService.get_current_user(session_id)

      if user.nil?
        env.response.status_code = 401
        env.response.content_type = "application/json"
        next {success: false, message: "Unauthorized: Invalid session"}.to_json
      end

      # Store the user in the environment for use in route handlers
      env.set("currentUserId", user.id)
    rescue e
      env.response.status_code = 401
      env.response.content_type = "application/json"
      next {success: false, message: "Unauthorized: #{e.message}"}.to_json
    end
  end

  options "/*" do |env|
    env.response.status_code = 200
    env.response.close
  end

  Kemal.run
end

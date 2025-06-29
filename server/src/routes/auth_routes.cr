require "kemal"
require "../dtos/**"
require "../services/auth_service"

post "/auth/sign-up" do |env|
  signUpDto = WatchingRoom::SignUpDto.from_json(env.request.body.not_nil!)

  user = WatchingRoom::AuthService.register(signUpDto)

  env.response.status_code = 200
  env.response.content_type = "application/json"

  if user.nil?
    env.response.status_code = 401
    {success: false, message: "Invalid credentials"}.to_json
  else
    if (user_id = user.id)
      session = WatchingRoom::SessionService.create(user_id)
      {success: true, session_id: session.session_id, user: user}.to_json
    end
  end
end

post "/auth/sign-in" do |env|
  signInDto = WatchingRoom::SignInDto.from_json(env.request.body.not_nil!)

  user = WatchingRoom::AuthService.authenticate(signInDto)

  env.response.status_code = 200
  env.response.content_type = "application/json"

  if user.nil?
    env.response.status_code = 401
    {success: false, message: "Invalid credentials"}.to_json
  else
    if (user_id = user.id)
      session = WatchingRoom::SessionService.create(user_id)
      {success: true, session_id: session.session_id, user: user}.to_json
    end
  end
end

require "../repositories/user_repository"
require "../models/user"
require "../dtos/sign-up.dto"
require "../dtos/sign-in.dto"
require "crypto/bcrypt/password"
require "uuid"

module WatchingRoom
  class AuthService
    def self.register(signUpDto : SignUpDto) : User
      user = User.new(
        id: UUID.random.to_s,
        email: signUpDto.email,
        username: signUpDto.username,
        fullname: signUpDto.fullname,
        password: Crypto::Bcrypt::Password.create(signUpDto.password, cost: 10).to_s
      )

      UserRepository.create(user)
    end

    def self.authenticate(signInDto : SignInDto) : User?
      user = UserRepository.find_by_username(signInDto.username)

      return nil if user.nil?

      hashed_password = Crypto::Bcrypt::Password.new(user.password)

      return user if hashed_password.verify(signInDto.password)

      nil
    end

    def self.get_current_user(session_id : String) : User | Nil
      session = SessionRepository.find_by_session_id(session_id)

      if session.nil?
        raise "Invalid session"
      end

      UserRepository.find_by_id(session.user_id)
    end
  end
end

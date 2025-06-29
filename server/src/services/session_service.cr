require "base64"
require "json"

module WatchingRoom
  class SessionService
    def self.create(user_id : String) : Session
      random_bytes = Random::Secure.random_bytes(32)
      timestamp = Time.utc.to_s
      input = random_bytes + timestamp.to_slice
      session_id = OpenSSL::Digest.new("sha256").update(input).final.hexstring

      expires_at = Time.utc + Time::Span.new(hours: 800)

      session = Session.new(
        session_id: session_id,
        user_id: user_id,
        expires_at: expires_at
      )

      SessionRepository.create(session)
    end
  end
end

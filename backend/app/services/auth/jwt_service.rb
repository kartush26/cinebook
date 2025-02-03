module Auth
  class JwtService
    ALGORITHM = 'HS256'.freeze

    def self.secret
      ENV.fetch('JWT_SECRET')
    end

    def self.access_ttl
      ENV.fetch('JWT_ACCESS_TTL_MIN', 15).to_i.minutes
    end

    def self.encode(payload, ttl: access_ttl)
      payload = payload.merge(
        exp: ttl.from_now.to_i,
        iat: Time.current.to_i,
        jti: SecureRandom.uuid
      )
      JWT.encode(payload, secret, ALGORITHM)
    end

    def self.decode!(token)
      JWT.decode(token, secret, true, algorithm: ALGORITHM).first
    rescue JWT::ExpiredSignature
      raise Auth::Errors::Unauthorized, 'Token expired'
    rescue JWT::DecodeError => e
      raise Auth::Errors::Unauthorized, "Invalid token: #{e.message}"
    end
  end
end

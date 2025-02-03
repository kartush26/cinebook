module Auth
  # Issues an access + refresh token pair and persists the refresh token's digest.
  # Implements refresh token rotation with reuse detection (token "families").
  class TokenIssuer
    REFRESH_TTL = (ENV.fetch('JWT_REFRESH_TTL_DAYS', 30).to_i).days

    Result = Struct.new(:access_token, :refresh_token, :access_expires_in, :user, keyword_init: true)

    def self.issue_for(user, family_id: nil, request: nil)
      access_payload = { sub: user.id, role: user.role, name: user.name }
      access_token   = Auth::JwtService.encode(access_payload)
      access_payload_decoded = Auth::JwtService.decode!(access_token) # to extract jti
      jti = access_payload_decoded['jti']

      raw_refresh = SecureRandom.urlsafe_base64(64)
      RefreshToken.create!(
        user:         user,
        token_digest: hash_token(raw_refresh),
        jti:          jti,
        family_id:    family_id || SecureRandom.uuid,
        user_agent:   request&.user_agent,
        ip:           request&.remote_ip,
        expires_at:   REFRESH_TTL.from_now
      )

      Result.new(
        access_token:      access_token,
        refresh_token:     raw_refresh,
        access_expires_in: Auth::JwtService.access_ttl.to_i,
        user:              user
      )
    end

    def self.rotate!(raw_refresh, request: nil)
      record = RefreshToken.find_by(token_digest: hash_token(raw_refresh))
      raise Auth::Errors::Unauthorized, 'Invalid refresh token' if record.nil?

      if record.revoked? || record.expired?
        # Token reuse — kill the entire family
        RefreshToken.where(family_id: record.family_id).update_all(revoked_at: Time.current)
        raise Auth::Errors::TokenReused, 'Refresh token reuse detected — all sessions revoked'
      end

      record.revoke!
      issue_for(record.user, family_id: record.family_id, request: request)
    end

    def self.revoke!(raw_refresh)
      RefreshToken.find_by(token_digest: hash_token(raw_refresh))&.revoke!
    end

    def self.hash_token(token)
      Digest::SHA256.hexdigest("#{token}#{Auth::JwtService.secret}")
    end
  end
end

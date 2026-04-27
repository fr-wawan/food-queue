class JwtService
  ALGORITHM = "HS256"
  EXPIRY = 24.hours

  def self.encode(payload)
    jti = SecureRandom.uuid
    exp = EXPIRY.from_now.to_i

    JWT.encode(
      payload.merge(jti: jti, exp: exp),
      secret,
      ALGORITHM
    )
  end

  def self.decode(token)
    JWT.decode(token, secret, true, algorithm: ALGORITHM).first
  rescue JWT::DecodeError => e
    raise AuthenticationError, e.message
  end

  def self.secret
    Rails.application.credentials.secret_key_base
  end
end

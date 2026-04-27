module AuthHelpers
  def auth_headers(user)
    token = JwtService.encode({ user_id: user.id, restaurant_id: user.restaurant_id })

    payload = JwtService.decode(token)

    user.sessions.create!(
      jti: payload['jti'],
      token_digest: BCrypt::Password.create(token),
      expires_at: Time.at(payload['exp']),
      user_agent: 'rspec',
      ip_address: "127.0.0.1"
    )
    { "Authorization" => "Bearer #{token}" }
  end
end

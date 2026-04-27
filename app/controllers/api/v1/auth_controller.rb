class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_request, only: [ :login ]

  def login
    restaurant = Restaurant.find_by!(subdomain: params[:subdomain])

    ActsAsTenant.with_tenant(restaurant) do
      user = restaurant.users.find_by!(email: params[:email])

      if user.authenticate(params[:password])
        token = issue_token(user)

        render json: { token: token, user: UserBlueprint.render_as_hash(user) }
      else
        render json: { error: "Invalid credentials" }, status: :unauthorized
      end
    end
  end

  def logout
    current_session.destroy!
    head :no_content
  end

  private

  def issue_token(user)
    token = JwtService.encode({ user_id: user.id, restaurant_id: user.restaurant_id })

    payload = JwtService.decode(token)

    user.sessions.create!(
      jti: payload["jti"],
      token_digest: BCrypt::Password.create(token),
      expires_at: Time.at(payload["exp"]),
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    )

    token
  end
end

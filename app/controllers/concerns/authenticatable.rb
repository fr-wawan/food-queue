module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    token = extract_token
    payload = JwtService.decode(token)

    restaurant = Restaurant.find(payload["restaurant_id"])

    ActsAsTenant.current_tenant = restaurant

    session_record = Session.find_by!(jti: payload["jti"])

    raise AuthenticationError, "Session expired" if session_record.expired?

    @current_user = session_record.user
    @current_session = session_record
  end

  def extract_token
    header = request.headers["Authorization"]

    raise AuthenticationError, "Missing token" unless header&.start_with?("Bearer ")
    header.split(" ").last
  end

  def current_user = @current_user
  def current_session = @current_session
end

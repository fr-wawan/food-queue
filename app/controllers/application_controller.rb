class ApplicationController < ActionController::API
  include Authenticatable

  rescue_from AuthenticationError, with: :unauthorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private

  def unauthorized(e)
    render json: { error: e.message }, status: :unauthorized
  end

  def not_found
    render json: { error: "Not found" }, status: :not_found
  end
end

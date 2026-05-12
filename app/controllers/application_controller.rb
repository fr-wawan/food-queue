class ApplicationController < ActionController::API
  include Authenticatable

  rescue_from AuthenticationError, with: :unauthorized
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_content

  private

  def unauthorized(e)
    render json: { error: e.message }, status: :unauthorized
  end

  def not_found
    render json: { error: "Not found" }, status: :not_found
  end

  def unprocessable_content(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  end
end

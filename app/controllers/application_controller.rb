class ApplicationController < ActionController::API
  include Authenticatable
  include Pundit::Authorization

  rescue_from ActiveRecord::RecordInvalid,   with: :handle_record_invalid
  rescue_from ActiveRecord::RecordNotFound,  with: :handle_not_found
  rescue_from AuthenticationError,           with: :handle_unauthorized
  rescue_from Pundit::NotAuthorizedError,    with: :handle_forbidden

  private

  def current_restaurant
    ActsAsTenant.current_tenant
  end

  def handle_record_invalid(e)
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
  end

  def handle_not_found
    render json: { errors: [ "Record not found" ] }, status: :not_found
  end

  def handle_unauthorized
    render json: { errors: [ "Unauthorized" ] }, status: :unauthorized
  end

  def handle_forbidden
    render json: { errors: [ "Forbidden" ] }, status: :forbidden
  end
end

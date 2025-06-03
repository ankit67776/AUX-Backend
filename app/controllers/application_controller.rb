class ApplicationController < ActionController::API
  before_action :authorize_request

  def authorize_request
    header = request.headers["Authorization"]
    token = header.split(" ").last if header
    decoded = JsonWebToken.decode(token)
    @current_user = User.find(decoded[:user_id]) if decoded
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { errors: "Unauthorized" }, status: :unauthorized
  end

  def authorize_advertiser
    render json: { error: "Forbidden" }, status: :forbidden unless @current_user&.role == "advertiser"
  end

  def authorize_publisher
    render json: { error: "Forbidden" }, status: :forbidden unless @current_user&.role == "publisher"
  end
end

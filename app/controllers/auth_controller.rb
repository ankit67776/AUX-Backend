class AuthController < ApplicationController
  skip_before_action :authorize_request, only: [ :register, :login ]

  def register
    user = User.new(user_params)
    if user.save
      token = JsonWebToken.encode(user_id: user.id, role: user.role)
      render json: { token:, user: user.slice(:id, :name, :email, :role) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id, role: user.role)
      render json: { token:, user: user.slice(:id, :name, :email, :role) }, status: :ok
    else
      render json: { errors: "Invalid credentials" }, status: :unauthorized
    end
  end

  private

  def user_params
    params.permit(:name, :email, :password, :password_confirmation, :role)
  end
end

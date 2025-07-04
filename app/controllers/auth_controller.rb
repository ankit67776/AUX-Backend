class AuthController < ApplicationController
  skip_before_action :authorize_request, only: [ :send_verification_code, :verify_code_and_register, :login ]

  def send_verification_code
    email = params[:email]&.downcase
    return render json: { error: "Email is required" }, status: :bad_request unless email

    code = rand(100000..999999).to_s
    cache_key = "verify:#{email}"

    Rails.cache.write(
      cache_key,
      {
        name: params[:name],
        role: params[:role],
        verification_code: code
      },
      expires_in: 15.minutes
    )

    UserMailer.send_verification_code(email, code, params[:name]).deliver_later
    render json: { message: "Verification code sent to #{email}" }, status: :ok
  end

  def verify_code_and_register
    email = params[:email]&.downcase
    cache_key = "verify:#{email}"
    cached = Rails.cache.read(cache_key)

    if cached.nil? || cached[:verification_code] != params[:verification_code]
      return render json: { errors: "Invalid or expired verification code" }, status: :unauthorized
    end

    user = User.new(
      name: cached[:name],
      email: email,
      role: cached[:role],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if user.save
      Rails.cache.delete(cache_key)
      token = JsonWebToken.encode(user_id: user.id, role: user.role)
      NewRelic::Agent.record_custom_event("UserRegistered", {
        user_id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        time: Time.current.to_s
      })

      render json: { token:, user: user.slice(:id, :name, :email, :role) }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email]&.downcase)
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id, role: user.role)
      NewRelic::Agent.record_custom_event("UserLogin", {
        user_id: user.id,
        email: user.email,
        role: user.role,
        time: Time.current.to_s
      })

      render json: { token:, user: user.slice(:id, :name, :email, :role) }, status: :ok
    else
      render json: { errors: "Invalid credentials" }, status: :unauthorized
    end
  end
end

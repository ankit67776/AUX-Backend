class UserMailer < ApplicationMailer
  def send_verification_code(email, code, name = nil)
    @code = code
    @name = name
    mail(to: email, subject: "Your verification code")
  end
end

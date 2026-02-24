class UserMailer < ApplicationMailer
  default from: -> { Setting.postmark_from_email }

  def verification_email(user)
    @user = user
    @verification_url = verify_email_url(@user.verification_token)

    mail(
      to: @user.email,
      subject: "Verify your KidComics account"
    )
  end

  def welcome_email(user)
    @user = user

    mail(
      to: @user.email,
      subject: "Welcome to KidComics!"
    )
  end
end

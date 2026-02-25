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

  def magic_link_email(user, token)
    @user = user
    @magic_link_url = magic_link_url(token)

    mail(
      to: @user.email,
      subject: "Continue your KidComics registration"
    )
  end
end

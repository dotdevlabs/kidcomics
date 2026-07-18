class UserMailer < ApplicationMailer
  default from: -> { Setting.postmark_from_email }

  def verification_email(user)
    @user = user
    @verification_url = verify_email_url(@user.verification_token)

    mail(
      to: @user.email,
      subject: t("user_mailer.verification_email.subject")
    )
  end

  def welcome_email(user)
    @user = user

    mail(
      to: @user.email,
      subject: t("user_mailer.welcome_email.subject")
    )
  end

  def magic_link_email(user, magic_link_url)
    @user = user
    @magic_link_url = magic_link_url

    mail(
      to: @user.email,
      subject: t("user_mailer.magic_link_email.subject")
    )
  end
end

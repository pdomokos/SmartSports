class UserMailer < ActionMailer::Base
  default from: "info@smartdiab.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.reset_password_email.subject
  #
  def reset_password_email(user)
    @user = user
    @url  = edit_password_reset_url(user.reset_password_token)
    logger.info "Sending mail with: "+@url

    mail(:to => user.email, :subject => "Your password has been reset") do |format|
      format.text
    end
  end

  def user_created_email(user)
    @user = user
    @url  = login_url
    logger.info "Sending mail with: "+@url

    mail(:to => user.email, :subject => "Your account is created!") do |format|
      format.text
    end
  end
end

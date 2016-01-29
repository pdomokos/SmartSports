class InfoMailJob < Struct.new(:mail_action, :email, :lang, :mail_params )

  def perform
    Delayed::Worker.logger.info("InfoMailJob perform, #{mail_action} to: #{email}")
    UserMailer.send(mail_action, self ).deliver
  end

  def max_attempts
    3
  end

end
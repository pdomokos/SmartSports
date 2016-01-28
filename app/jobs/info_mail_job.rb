class InfoMailJob < Struct.new(:mail_action, :email, :lang, :mail_params )

  def perform
    puts "InfoMailJob.perform called"
    Delayed::Worker.logger.info("InfoMailJob perform")
    Delayed::Worker.logger.info(self.to_json)

    UserMailer.send(mail_action, self ).deliver
  end

  def max_attempts
    3
  end

end
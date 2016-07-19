class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :custom_form
  enum notification_type: { friend: 0, doctors_visit_general: 1 , doctors_visit_specialist: 2, doctor: 10, medication: 11, reminder: 12, motivation: 13}

  def send_push()
    user = self.user
    if not user.dev_token.nil?
      pusher = Grocer.pusher(
          certificate: CONNECTION_CONFIG["NOTIF_CERT"],      # required
          passphrase:  CONNECTION_CONFIG["NOTIF_PASS"],                       # optional
          gateway: "gateway.sandbox.push.apple.com",
          port: 2195,
          retries:     3                         # optional
      )

      msg = ""
      if not self.title.nil?
        msg = msg + self.title
      end
      if not self.detail.nil?
        msg = msg + " " + self.detail
      end
      if msg==""
        msg = "Empty message"
      end

      notif_data = {
          user_name: user.username,
          user_id: user.id,
          notification_id: self.id,
          form_name: self.form_name
      }
      logger.debug("Notif data:")
      logger.debug(JSON.pretty_generate(notif_data))
      notification = Grocer::Notification.new(
          device_token:      user.dev_token.upcase,
          alert:             msg,
          badge:             42,
          category:          "a category",         # optional; used for custom notification actions
          sound:             "siren.aiff",         # optional
          expiry:            Time.now + 60*60,     # optional; 0 is default, meaning the message is not stored
          # identifier:        1234,                 # optional; must be an integer
          content_available: true,                  # optional; any truthy value will set 'content-available' to 1
          custom: notif_data
      )

      pusher.push(notification)
    end
  end
  handle_asynchronously :send_push, :run_at => Proc.new { |n| n.date }

end

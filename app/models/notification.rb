class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :custom_form
  enum notification_type: { friend: 0, doctors_visit_general: 1 , doctors_visit_specialist: 2, doctor: 10, medication: 11, reminder: 12, motivation: 13}
end

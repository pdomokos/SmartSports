class Notification < ActiveRecord::Base
  belongs_to :user
  enum notification_type: { friend: 0, doctors_visit_general: 1 , doctors_visit_specialist: 2, doctor: 10, medication: 11, form_fill: 12, motivation: 13}
end

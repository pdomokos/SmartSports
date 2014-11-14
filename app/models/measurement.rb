class Measurement < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true
  # validates :systolicbp, :numericality => true
  # validates :diastolicbp, :numericality => true
  # validates :pulse, :numericality => true
  # validates :SPO2, :numericality => true

end

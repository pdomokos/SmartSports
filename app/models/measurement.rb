class Measurement < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true
  validates :systolicbp, :numericality => true, :allow_nil => true
  validates :diastolicbp, :numericality => true, :allow_nil => true
  validates :pulse, :numericality => true, :allow_nil => true
  validates :blood_sugar, :numericality => true, :allow_nil => true
  validates :weight, :numericality => true, :allow_nil => true
  validates :waist, :numericality => true, :allow_nil => true
  # validates :SPO2, :numericality => true

end

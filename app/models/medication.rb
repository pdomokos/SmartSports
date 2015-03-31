class Medication < ActiveRecord::Base
  belongs_to :user
  belongs_to :medication_type
  validates :medication_type_id, :presence => true
  validates :user_id, :presence => true
  validates :date, :presence => true
  validates :amount, :numericality => true, :allow_nil => true
end

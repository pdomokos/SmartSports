class Medication < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true
  validates :date, presence: true
  validates :name, presence: true
  validates :amount, :numericality => true, :allow_nil => true
end

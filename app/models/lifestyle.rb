class Lifestyle < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  # validates :name, presence: true
  validates :start_time, presence: true
  validates :amount, :numericality => true, :allow_nil => true
end

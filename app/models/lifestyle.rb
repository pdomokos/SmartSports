class Lifestyle < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :group, presence: true
  validates :start_time, presence: true
  validates :amount, :numericality => true, :allow_nil => true
end

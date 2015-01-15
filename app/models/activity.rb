class Activity < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :steps, allow_blank: true, numericality: {only_integer: true}
  validates :duration, allow_blank: true, numericality: true
end

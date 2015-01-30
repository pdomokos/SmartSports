class Summary < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :steps, numericality: {only_integer: true}, allow_nil: true
  validates :total_duration, numericality: true, allow_nil: true
end

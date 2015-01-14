class Summary < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :steps, numericality: {only_integer: true}
  validates :total_duration, numericality: true
end

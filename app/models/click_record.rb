class ClickRecord < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :operation_time, presence: true
  validates :operation, presence: true
  validates :url, presence: true
end

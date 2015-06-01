class Profile < ActiveRecord::Base
  belongs_to :user
  validates :weight, numericality: true, allow_nil: true
  validates :height, numericality: true, allow_nil: true
end

class Profile < ActiveRecord::Base
  belongs_to :user
  validates :weight, numericality: { only_integer: true }, allow_nil: true
  validates :height, numericality: { only_integer: true }, allow_nil: true
end

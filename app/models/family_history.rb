class FamilyHistory < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates :relative, presence: true
  validates :disease, presence: true
end

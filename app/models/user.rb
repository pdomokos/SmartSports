class User < ActiveRecord::Base
  has_many :connections
  has_many :activities
  has_many :measurements
  authenticates_with_sorcery!
  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true
  validates :email, uniqueness: true

end

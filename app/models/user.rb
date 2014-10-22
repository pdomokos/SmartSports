class User < ActiveRecord::Base
  has_many :connections
  belongs_to :connection
  has_many :activities
  authenticates_with_sorcery!
  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true
  validates :email, uniqueness: true

end

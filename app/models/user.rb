class User < ActiveRecord::Base
  has_many :connections
  has_many :activities
  has_many :measurements
  has_many :diets
  has_many :medications
  has_many :lifestyles
  has_many :family_histories
  has_many :notifications
  authenticates_with_sorcery!
  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true
  validates :email, uniqueness: true

  def is_friend?(fid)
    f = Friendship.where("authorized = 't' and (( user1_id = #{self.id} and user2_id = #{fid} ) or ( user1_id = #{fid} and user2_id = #{self.id} ))")
    return (f.size == 1)
  end
end

class User < ActiveRecord::Base
  has_many :connections
  has_many :activities
  has_many :measurements
  has_many :diets
  has_many :medications
  has_many :lifestyles
  has_many :family_histories
  has_many :notifications
  has_many :sensor_measurements
  has_many :lab_results
  has_many :click_records
  has_many :tracker_data
  has_many :summaries
  has_one :profile
  authenticates_with_sorcery!
  validates :password, length: { minimum: 4, message: "error_registration_password"}, allow_nil: true
  validates :password, confirmation: true
  validates :password_confirmation, presence: { message: "error_registration_password_confirmation"}, if: :password
  validates :email, uniqueness: { message: "error_registration_email_used"}
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create, message: "error_registration_email_format"}

  has_attached_file :avatar, :styles => { :medium => "150x200>", :thumb => "75x100>" },
                    :default_url => ":style/unknown.png",
                    :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
                    :path => APP_CONFIG['PAPERCLIP_PATH']

  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  def is_friend?(fid)
    f = Friendship.where("authorized = 't' and (( user1_id = #{self.id} and user2_id = #{fid} ) or ( user1_id = #{fid} and user2_id = #{self.id} ))")
    return (f.size == 1)
  end

  def has_profile
    p = Profile.where("user_id = #{self.id}")
    return (p.size == 1)
  end
end

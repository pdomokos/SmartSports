class Diet < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true

  def as_json(options={})
    super(options.merge({:methods => :type}))
  end
end

class Connection < ActiveRecord::Base
  belongs_to :user
  serialize :data, Hash
end

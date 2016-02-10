class Connection < ActiveRecord::Base
  belongs_to :user
  enum sync_status: {never: 0, pending: 1, success: 2, failure: 3}
end

class AddNotificationScheduleData < ActiveRecord::Migration
  def change
    add_column :users, :doctor, :boolean
    add_column :notifications, :dismissed_on, :datetime
    add_column :notifications, :dismissed, :boolean
    add_column :notifications, :recurring, :boolean
  end
end

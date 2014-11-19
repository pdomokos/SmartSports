class AddDataToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :notification_data, :string
  end
end

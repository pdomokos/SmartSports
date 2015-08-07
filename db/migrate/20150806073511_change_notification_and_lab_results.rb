class ChangeNotificationAndLabResults < ActiveRecord::Migration
  def change
    change_column :notifications, :notification_type, :integer
    add_column :notifications, :remind_at, :datetime
    remove_columns :lab_results, :controll_type, :remainder_date
  end
end

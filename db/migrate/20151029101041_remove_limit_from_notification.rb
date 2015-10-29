class RemoveLimitFromNotification < ActiveRecord::Migration
  def up
	change_column :notifications, :notification_type, :integer, :limit => 2
	change_column :connections, :data, :text, :limit => 1024
	change_column :sensor_measurements, :hr_data, :text, :limit => 2097152
	change_column :sensor_measurements, :rr_data, :text, :limit => 2097152
	change_column :sensor_measurements, :cr_data, :text, :limit => 2097152
	change_column :sensor_segments, :data_a, :text, :limit => 2097152
	change_column :sensor_segments, :data_b, :text, :limit => 2097152
  end

  def down
        change_column :notifications, :notification_type, :integer, :limit => nil
  end
end

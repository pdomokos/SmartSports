class AddEndTimeToSensorData < ActiveRecord::Migration
  def change
    add_column :sensor_measurements, :end_time, :datetime
  end
end

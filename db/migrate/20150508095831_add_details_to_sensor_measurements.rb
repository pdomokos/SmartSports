class AddDetailsToSensorMeasurements < ActiveRecord::Migration
  def change
    add_column :sensor_measurements, :duration, :integer
    add_column :sensor_measurements, :sensors, :string
    add_column :sensor_measurements, :favourite, :boolean
  end
end

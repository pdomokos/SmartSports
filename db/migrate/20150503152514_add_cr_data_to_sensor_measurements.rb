class AddCrDataToSensorMeasurements < ActiveRecord::Migration
  def change
    add_column :sensor_measurements, :cr_data, :text
  end
end

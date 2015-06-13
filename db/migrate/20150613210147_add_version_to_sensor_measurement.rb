class AddVersionToSensorMeasurement < ActiveRecord::Migration
  def change
    add_column :sensor_measurements, :version, :string
  end
end

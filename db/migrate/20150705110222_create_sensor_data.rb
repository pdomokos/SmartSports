class CreateSensorData < ActiveRecord::Migration
  def change
    create_table :sensor_data do |t|
      t.string :sensor_id
      t.string :sensor_type
      t.references :sensor_measurement, index: true

      t.timestamps
    end
  end
end

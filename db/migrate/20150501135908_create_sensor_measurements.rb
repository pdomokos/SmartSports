class CreateSensorMeasurements < ActiveRecord::Migration
  def change
    create_table :sensor_measurements do |t|
      t.integer :user_id
      t.string :group
      t.text :rr_data
      t.text :hr_data
      t.datetime :start_time
    end
  end
end

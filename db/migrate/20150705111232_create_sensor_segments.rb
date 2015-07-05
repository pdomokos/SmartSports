class CreateSensorSegments < ActiveRecord::Migration
  def change
    create_table :sensor_segments do |t|
      t.datetime :start_time
      t.text :data_a
      t.text :data_b
      t.references :sensor_datum, index: true

      t.timestamps
    end
  end
end

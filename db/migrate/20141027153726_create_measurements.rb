class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.references :user, index: true
      t.integer :user_id
      t.string :source
      t.datetime :date
      t.integer :diastolicbp
      t.integer :systolicbp
      t.integer :pulse
      t.integer :SPO2

      t.timestamps
    end
    add_index :measurements, [:user_id, :created_at]
  end
end

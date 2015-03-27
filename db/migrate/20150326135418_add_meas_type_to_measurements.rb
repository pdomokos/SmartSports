class AddMeasTypeToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :meas_type, :string
  end
end

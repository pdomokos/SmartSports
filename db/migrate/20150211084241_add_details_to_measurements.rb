class AddDetailsToMeasurements < ActiveRecord::Migration
  def change
    add_column :measurements, :blood_sugar, :float
    add_column :measurements, :weight, :float
    add_column :measurements, :waist, :float
  end
end

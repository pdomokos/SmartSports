class AddBloodSugarTimeToMeasurement < ActiveRecord::Migration
  def change
    add_column :measurements, :blood_sugar_time, :integer
  end
end

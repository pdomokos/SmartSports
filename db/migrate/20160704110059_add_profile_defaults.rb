class AddProfileDefaults < ActiveRecord::Migration
  def change
    change_column :profiles, :blood_glucose_min, :float, :default => 4.0
    change_column :profiles, :blood_glucose_max, :float, :default => 8.0
    change_column :profiles, :carb_min, :integer, :default => 5
    change_column :profiles, :carb_max, :integer, :default => 500
  end
end

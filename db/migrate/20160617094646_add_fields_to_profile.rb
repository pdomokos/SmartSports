class AddFieldsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :blood_glucose_min, :float
    add_column :profiles, :blood_glucose_max, :float
    add_column :profiles, :blood_glucose_unit, :string, default: "mmol/L"
  end
end

class AddCarbFieldsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :carb_min, :integer
    add_column :profiles, :carb_max, :integer
  end
end

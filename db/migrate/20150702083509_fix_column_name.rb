class FixColumnName < ActiveRecord::Migration
  def change
    rename_column :diets, :type, :diet_type
  end
end

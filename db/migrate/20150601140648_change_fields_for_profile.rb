class ChangeFieldsForProfile < ActiveRecord::Migration
  def change
    change_column :profiles, :height,  :float
    change_column :profiles, :weight,  :float
  end
end

class ChangeProfile < ActiveRecord::Migration
  def change
    change_column :profiles, :dateofbirth, :integer
  end
end

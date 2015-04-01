class AddEndTimeToLifestyles < ActiveRecord::Migration
  def change
    add_column :lifestyles, :end_time, :datetime
    remove_column :lifestyles, :data, :text
    add_index :lifestyles, [:user_id, :group]
  end
end

class RemoveGroupFromLifestyles < ActiveRecord::Migration
  def up
    remove_column :lifestyles, :group
  end

  def down
    add_column :lifestyles, :group, :string
  end
end

class ModifyActivity < ActiveRecord::Migration
  def up
    remove_column :activities, :activity_type_name
    remove_column :activities, :activity
  end

  def down
    add_column :activities, :activity_type_name, :string
    add_column :activities, :activity, :string
  end
end

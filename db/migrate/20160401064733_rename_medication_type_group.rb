
class RenameMedicationTypeGroup < ActiveRecord::Migration
  def up
    rename_column :medication_types, :group, :category
    add_column :medication_types, :title, :string
    add_index :medication_types, :title
  end

  def down
    remove_index :medication_types, :title
    remove_column :medication_types, :title
    rename_column :medication_types, :category, :group
  end
end

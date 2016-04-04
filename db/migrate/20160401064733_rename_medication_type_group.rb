class RenameMedicationTypeGroup < ActiveRecord::Migration
  def up
    rename_column :medication_types, :group, :category
    rename_column :medication_types, :name, :title
    add_column :medication_types, :name, :string
    add_index :medication_types, :name
  end

  def down
    remove_index :medication_types, :name
    rename_column :medication_types, :category, :group
    rename_column :medication_types, :title, :name
  end
end

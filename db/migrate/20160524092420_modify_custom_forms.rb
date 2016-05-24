class ModifyCustomForms < ActiveRecord::Migration
  def change
    add_column :custom_forms, :favourite, :boolean, :default => false
    add_column :custom_forms, :created_at, :datetime
  end
end

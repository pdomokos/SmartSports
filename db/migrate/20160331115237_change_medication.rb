class ChangeMedication < ActiveRecord::Migration
  def change
    add_column :medications, :custom_medication_type_id, :integer
    add_column :medications, :custom_medication_type_key, :string
    add_column :medications, :custom_medication_type_name, :string
  end
end

class AddMedicationTypeIdToMedications < ActiveRecord::Migration
  def change
    add_column :medications, :medication_type_id, :integer
    remove_column :medications, :group, :string
    remove_column :medications, :name, :string
  end
end

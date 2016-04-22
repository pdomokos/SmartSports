class AddCustomMedicationTypeIdToMedication < ActiveRecord::Migration
  def change
    add_column :medications, :custom_medication_type_id, :integer
  end
end

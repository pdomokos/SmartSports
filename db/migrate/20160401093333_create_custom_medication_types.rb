class CreateCustomMedicationTypes < ActiveRecord::Migration
  def change
    create_table :custom_medication_types do |t|
      t.integer :medication_id
      t.string :key
      t.string :category
      t.string :name
      t.float :dosage
    end
  end
end

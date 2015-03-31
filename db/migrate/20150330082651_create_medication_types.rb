class CreateMedicationTypes < ActiveRecord::Migration
  def change
    create_table :medication_types do |t|
      t.string :group
      t.string :name
      t.float :dosage
    end
  end
end

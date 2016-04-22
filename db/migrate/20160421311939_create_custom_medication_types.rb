class CreateCustomMedicationTypes < ActiveRecord::Migration
  def change
    create_table :custom_medication_types do |t|
       t.string :key
       t.string :category
       t.string :name
    end
  end
end

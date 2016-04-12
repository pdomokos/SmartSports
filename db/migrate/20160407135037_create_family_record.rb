class CreateFamilyRecord < ActiveRecord::Migration
    def change
      create_table :family_records do |t|
        t.references :user
        t.string :source
        t.string :diabetes_key
        t.string :relative_key
        t.text :note

        t.timestamps
      end
      add_index :family_records, [:user_id]
    end
end

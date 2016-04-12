class CreatePersonalRecord < ActiveRecord::Migration
  def change
    create_table :personal_records do |t|
      t.references :user
      t.string :source
      t.string :diabetes_key
      t.string :antibody_key
      t.text :note
      t.boolean :antibody_kind
      t.string :antibody_value

      t.timestamps
    end
    add_index :personal_records, [:user_id]
  end
end

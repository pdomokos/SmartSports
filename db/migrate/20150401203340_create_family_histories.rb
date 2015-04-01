class CreateFamilyHistories < ActiveRecord::Migration
  def change
    create_table :family_histories do |t|
      t.references :user
      t.string :source
      t.string :relative
      t.string :disease
      t.text :note

      t.timestamps
    end
    add_index :family_histories, [:user_id]
    add_index :family_histories, [:user_id, :source]
    add_index :family_histories, [:user_id, :created_at]
  end
end

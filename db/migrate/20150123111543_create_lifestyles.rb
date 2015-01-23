class CreateLifestyles < ActiveRecord::Migration
  def change
    create_table :lifestyles do |t|
      t.references :user, index: true
      t.datetime :start_time
      t.string :source
      t.string :group
      t.string :name
      t.float :amount
      t.text :data

      t.timestamps
    end
    add_index :lifestyles, [:user_id, :created_at]
    add_index :lifestyles, [:user_id, :name]
  end
end

class CreateMedications < ActiveRecord::Migration
  def change
    create_table :medications do |t|
      t.integer  :user_id
      t.datetime :date
      t.string :source
      t.string :group
      t.string :name
      t.integer :amount
      t.timestamps
    end
  end
end

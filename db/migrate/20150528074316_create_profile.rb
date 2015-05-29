class CreateProfile < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :user, index: true
      t.string :firstname
      t.string :lastname
      t.integer :weight
      t.integer :height
      t.string :sex
      t.date :dateofbirth

      t.timestamps
    end
  end
end

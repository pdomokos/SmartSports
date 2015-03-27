class CreateDiets < ActiveRecord::Migration
  def change
    create_table :diets do |t|
      t.integer :user_id
      t.string :type
      t.string :source
      t.text :name
      t.datetime :date
      t.float :calories
      t.float :carbs
      t.integer :amount

      t.timestamps
    end
  end
end

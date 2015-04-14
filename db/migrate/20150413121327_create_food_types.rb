class CreateFoodTypes < ActiveRecord::Migration
  def change
    create_table :food_types do |t|
      t.string :name
      t.string :category
      t.string :amount
      t.float :kcal
      t.float :prot
      t.float :carb
      t.float :fat
    end
  end
end

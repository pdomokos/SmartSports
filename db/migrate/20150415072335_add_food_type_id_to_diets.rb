class AddFoodTypeIdToDiets < ActiveRecord::Migration
  def change
    add_column :diets, :food_type_id, :integer
  end
end

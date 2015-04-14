class ChangeAmountForDiet < ActiveRecord::Migration
  def change
    change_column :diets, :amount,  :float
  end
end

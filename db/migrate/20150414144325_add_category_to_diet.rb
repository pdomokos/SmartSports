class AddCategoryToDiet < ActiveRecord::Migration
  def change
    add_column :diets, :category, :string
  end
end

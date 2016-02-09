class AddLangToFoodType < ActiveRecord::Migration
  def change
    add_column :food_types, :lang, :string
  end
end

class AddFavouriteToDiet < ActiveRecord::Migration
  def change
    add_column :diets, :favourite, :boolean, :default => false
  end
end

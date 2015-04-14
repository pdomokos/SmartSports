class AddFatToDiet < ActiveRecord::Migration
  def change
    add_column :diets, :fat, :float
    add_column :diets, :prot, :float
  end
end

class AddFavourites < ActiveRecord::Migration
  def change
    add_column :activities, :favourite, :boolean, :default => false
    add_column :lifestyles, :favourite, :boolean, :default => false
    add_column :measurements, :favourite, :boolean, :default => false
    add_column :medications, :favourite, :boolean, :default => false
  end
end

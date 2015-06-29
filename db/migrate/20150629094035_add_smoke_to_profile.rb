class AddSmokeToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :smoke, :boolean, :default => false
    add_column :profiles, :insulin, :boolean, :default => false
  end
end

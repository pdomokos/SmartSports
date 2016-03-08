class DropFamilyHistoriesTable < ActiveRecord::Migration
  def change
    drop_table :family_histories
  end
end

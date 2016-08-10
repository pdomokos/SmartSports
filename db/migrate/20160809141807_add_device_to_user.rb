class AddDeviceToUser < ActiveRecord::Migration
  def change
    add_column :users, :device, :integer, :default => 0
  end
end

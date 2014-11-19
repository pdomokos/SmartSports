class ChangeConnectionIndex < ActiveRecord::Migration
  def change
    remove_index :connections, :name => "index_connection_on_name"
    add_index "connections", ["name", "user_id"], name: "index_connection_on_name_and_user_id", unique: true
  end
end

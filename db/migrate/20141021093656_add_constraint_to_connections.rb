class AddConstraintToConnections < ActiveRecord::Migration
  def change
    add_index("connections", ["name"], {name: "index_connection_on_name", unique: true})
  end
end
class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.string :name
      t.string :type
      t.string :data

      t.timestamps
    end
  end
end

class CreateConnections < ActiveRecord::Migration
  def change
    create_table :connections do |t|
      t.string :name
      t.string :type
      t.text :data

      t.timestamps
    end
  end
end
class DropGeneticsTypesTable < ActiveRecord::Migration

  def up
    drop_table :genetics_types
  end

  def down
    create_table :genetics_types do |t|
      t.string :name
      t.string :category
      t.string :lang
    end
  end

end

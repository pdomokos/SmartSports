class CreateGeneticsTypes < ActiveRecord::Migration
  def change
    create_table :genetics_types do |t|
      t.string :name
      t.string :category
    end
  end
end

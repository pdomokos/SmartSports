class AddLangToActivityType < ActiveRecord::Migration
  def change
    add_column :activity_types, :lang, :string
  end
end

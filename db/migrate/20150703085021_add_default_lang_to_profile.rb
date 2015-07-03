class AddDefaultLangToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :default_lang, :string
  end
end

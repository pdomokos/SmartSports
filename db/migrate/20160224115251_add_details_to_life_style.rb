class AddDetailsToLifeStyle < ActiveRecord::Migration
  def change
    add_column :lifestyles, :details, :text
  end
end

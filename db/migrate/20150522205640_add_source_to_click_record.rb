class AddSourceToClickRecord < ActiveRecord::Migration
  def change
    add_column :click_records, :source, :string
  end
end

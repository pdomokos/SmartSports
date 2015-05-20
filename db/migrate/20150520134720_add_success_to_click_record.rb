class AddSuccessToClickRecord < ActiveRecord::Migration
  def change
    add_column :click_records, :success, :boolean
  end
end

class AddRowIdToClickRecords < ActiveRecord::Migration
  def change
    add_column :click_records, :row_id, :integer
    add_column :click_records, :msg, :string
  end
end

class CreateClickRecords < ActiveRecord::Migration
  def change
    create_table :click_records do |t|
      t.references :user, index: true
      t.datetime :operation_time
      t.string :operation
      t.string :url
      t.string :data

      t.timestamps
    end
    add_index :click_records, [:user_id, :operation_time, :operation], name: "index_click_records"
  end
end

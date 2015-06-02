class CreateTrackerData < ActiveRecord::Migration
  def change
    create_table :tracker_data do |t|
      t.references :user, index: true
      t.string :source
      t.datetime :start_time
      t.datetime :end_time
      t.string :activity
      t.string :group
      t.boolean :manual
      t.float :duration
      t.float :distance
      t.integer :steps
      t.string :intensity
      t.float :calories
      t.datetime :synced_at
      t.boolean :sync_final

      t.timestamps
    end
    add_index :tracker_data, [:user_id, :start_time]
    add_index :tracker_data, [:user_id, :start_time, :sync_final]
  end
end

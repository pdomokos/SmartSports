class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user, index: true
      t.integer :game_id
      t.boolean :manual
      t.string :source
      t.string :group
      t.string :activity
      t.datetime :start_time
      t.datetime :end_time
      t.integer :steps
      t.integer :duration
      t.float :distance
      t.float :elevation
      t.float :calories
      t.timestamps
    end
    add_index :activities, [:user_id, :created_at]
  end
end

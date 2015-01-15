class CreateOldActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.references :user, index: true
      t.string :source
      t.datetime :date
      t.string :activity
      t.string :group
      t.float :duration
      t.float :distance
      t.integer :steps
      t.float :calories
      t.float :elevation
      t.datetime :last_update

      t.timestamps
    end
    add_index :activities, [:user_id, :created_at]
  end

end

class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :user, index: true
      t.string :title
      t.text :detail
      t.string :notification_type
      t.datetime :date

      t.timestamps
    end
    add_index :notifications, [:user_id, :date]
  end
end

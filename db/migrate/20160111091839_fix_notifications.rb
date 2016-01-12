class FixNotifications < ActiveRecord::Migration
  def change
    remove_column :notifications, :custom_form_id
    add_column :notifications, :recurrence_data, :string
    add_column :notifications, :form_name, :string
    add_column :notifications, :default_data, :string
  end
end

class AddFieldsToNotifications < ActiveRecord::Migration
  def change
    add_column :notifications, :created_by, :integer
    add_column :notifications, :form_id, :integer
    add_column :notifications, :location, :text
    add_column :notifications, :location_url, :text
  end
end

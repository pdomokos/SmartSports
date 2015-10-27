class AddFormTagToCustomForms < ActiveRecord::Migration
  def change
    add_column :custom_forms, :form_tag, :string
    add_column :notifications, :custom_form_id, :integer
  end
end

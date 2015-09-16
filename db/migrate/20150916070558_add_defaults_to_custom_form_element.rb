class AddDefaultsToCustomFormElement < ActiveRecord::Migration
  def change
    add_column :custom_form_elements, :defaults, :text
    remove_column :custom_form_elements, :template_id
    remove_column :diets, :is_template
    remove_column :activities, :is_template
    remove_column :measurements, :is_template
    remove_column :medications, :is_template
    remove_column :lifestyles, :is_template
    remove_column :notifications, :is_template
    remove_column :lab_results, :is_template
  end
end

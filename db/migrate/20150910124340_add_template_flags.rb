class AddTemplateFlags < ActiveRecord::Migration
  def change
    add_column :diets, :is_template, :boolean, default: false
    add_column :activities, :is_template, :boolean, default: false
    add_column :measurements, :is_template, :boolean, default: false
    add_column :medications, :is_template, :boolean, default: false
    add_column :lifestyles, :is_template, :boolean, default: false
    add_column :notifications, :is_template, :boolean, default: false
    add_column :lab_results, :is_template, :boolean, default: false
  end
end

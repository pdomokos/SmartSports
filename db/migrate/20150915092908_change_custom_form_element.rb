class ChangeCustomFormElement < ActiveRecord::Migration
  def change
    rename_column :custom_form_elements, :formId, :custom_form_id
    rename_column :custom_form_elements, :propertyCode, :property_code
    rename_column :custom_form_elements, :templateId, :template_id
    rename_column :custom_form_elements, :orderIndex, :order_index
  end
end

class CreateCustomFormElements < ActiveRecord::Migration
  def change
    create_table :custom_form_elements do |t|
      t.integer :formId
      t.integer :orderIndex
      t.string :propertyCode
      t.integer :templateId
    end
  end
end

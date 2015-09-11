class CreateCustomForms < ActiveRecord::Migration
  def change
    create_table :custom_forms do |t|
      t.integer :user_id
      t.integer :order_index
      t.string :form_name
      t.string :image_name
    end
  end
end

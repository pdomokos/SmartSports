json.extract! @customForm, :id, :user_id, :form_name, :form_tag, :image_name, :order_index
json.custom_form_elements @customForm.custom_form_elements do |elem|
  json.id elem.id
  json.property_code elem.property_code
  json.defaults JSON.parse(elem.defaults) if elem.defaults
  json.order_index elem.order_index
end

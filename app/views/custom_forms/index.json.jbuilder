json.array!(@custom_forms) do |cf|
  json.extract! cf, :id, :user_id, :form_name, :image_name, :order_index
  json.custom_form_elements cf.custom_form_elements do |elem|
    json.id elem.id
    json.property_code elem.property_code
    json.template_id elem.template_id
    json.order_index elem.order_index
  end
end

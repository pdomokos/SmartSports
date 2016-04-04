json.array!(@medication_types) do |medication_type|
  json.extract! medication_type, :id, :category, :name
  json.en medication_type.title if medication_type.category.ends_with?("_en")
  json.hu medication_type.title if not medication_type.category.ends_with?("_en")
end

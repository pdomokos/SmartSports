json.array!(@custom_medication_types) do |custom_medication_type|
  json.extract! custom_medication_type, :id, :category, :name
  json.label custom_medication_type.name
end

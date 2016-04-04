json.extract! @medication_type, :id, :name, :category
json.en @medication_type.title if @medication_type.category.ends_with?("_en")
json.hu @medication_type.title if not @medication_type.category.ends_with?("_en")

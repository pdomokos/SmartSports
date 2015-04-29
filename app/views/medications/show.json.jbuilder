json.extract! @medication, :id, :user_id, :date,:source, :amount, :created_at, :updated_at, :medication_type_id, :favourite
json.medication_type @medication.medication_type.group if @medication.medication_type
json.medication_name @medication.medication_type.name if @medication.medication_type
json.array!(@medications) do |medication|
  json.extract! medication, :id, :user_id, :date, :source, :amount, :created_at, :updated_at, :favourite
  json.name medication.medication_type.name if medication.medication_type
  json.category medication.medication_type.category if medication.medication_type
end

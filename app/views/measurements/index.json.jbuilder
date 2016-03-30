json.array!(@measurements) do |measurement|
  json.extract! measurement, :user_id, :source, :date, :diastolicbp, :systolicbp, :pulse, :blood_sugar, :weight, :waist, :meas_type, :favourite, :stress_amount
end
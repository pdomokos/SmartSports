json.array!(@measurements) do |measurement|
  json.extract! measurement, :id, :user_id, :source, :date, :diastolicbp, :systolicbp, :pulse, :blood_sugar, :weight, :waist, :meas_type, :favourite, :stress_level
end


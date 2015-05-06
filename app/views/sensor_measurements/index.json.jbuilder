json.array!(@sensor_measurements) do |sensor|
  json.extract! sensor, :id, :user_id, :group, :start_time
end

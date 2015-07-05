json.extract! @sensor_measurement, :id, :user_id, :group, :start_time, :rr_data, :hr_data, :cr_data, :duration, :sensors, :version
json.sensor_data @sensor_measurement.sensor_data do |sensor_data|
  json.sensor_id sensor_data.sensor_id
  json.sensor_type sensor_data.sensor_type
  json.sensor_segments sensor_data.sensor_segments do |segment|
    json.start_time segment.start_time
    json.data_a segment.data_a
    json.data_b segment.data_b
  end
end
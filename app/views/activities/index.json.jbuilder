json.array!(@activities) do |activity|
  json.extract! activity, :id, :user_id, :source, :activity, :group, :game_id, :start_time, :end_time, :steps, :duration, :distance, :calories, :manual
  json.url activity_url(activity, format: :json)
end

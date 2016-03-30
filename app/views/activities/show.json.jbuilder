json.extract! @activity, :id, :user_id, :source, :group, :game_id, :start_time, :end_time, :steps, :duration, :distance, :calories, :manual, :intensity, :created_at, :updated_at, :favourite, :activity_type_id
json.name @activity.activity_type.name if @activity.activity_type
json.category @activity.activity_type.category if @activity.activity_type

json.array!(@lifestyles) do |lifestyle|
  json.extract! lifestyle, :id, :user_id, :lifestyle_type_id, :source, :name, :details, :amount, :period_volume, :start_time, :end_time
  json.name lifestyle.lifestyle_type.name if lifestyle.lifestyle_type
  json.category lifestyle.lifestyle_type.category if lifestyle.lifestyle_type
end

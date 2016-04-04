json.array!(@lifestyles) do |lifestyle|
  json.extract! lifestyle, :id, :user_id, :lifestyle_type_id, :lifestyle_type_name, :source, :name, :details, :amount, :period_volume
  json.name lifestyle.lifestyle_type.name if lifestyle.lifestyle_type
  json.category lifestyle.lifestyle_type.category if lifestyle.lifestyle_type
end

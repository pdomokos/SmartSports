json.array!(@lifestyles) do |lifestyle|
  json.extract! lifestyle, :id, :user_id, :lifestyle_type_id, :lifestyle_type_name, :source, :name, :details, :amount, :period_volume
end

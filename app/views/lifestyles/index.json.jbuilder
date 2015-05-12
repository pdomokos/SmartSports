json.array!(@lifestyles) do |lifestyle|
  json.extract! lifestyle, :id, :user_id, :illness_type_id, :pain_type_name, :source, :group, :name, :amount, :period_volume, :data
  json.url lifestyle_url(lifestyle, format: :json)
end

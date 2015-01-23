json.array!(@lifestyles) do |lifestyle|
  json.extract! lifestyle, :id, :user_id, :source, :group, :name, :amount, :data
  json.url lifestyle_url(lifestyle, format: :json)
end

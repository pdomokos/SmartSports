json.array!(@connections) do |conn|
  json.extract! conn, :id, :name, :created_at, :synced_at, :sync_status
end

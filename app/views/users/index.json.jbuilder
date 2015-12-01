json.array!(@users) do |user|
  json.extract! user, :id, :name, :username, :email, :created_at, :updated_at, :admin, :doctor
  json.url user_url(user, format: :json)
  json.avatar_url user.avatar.url(:medium)
end

json.extract! @user, :id, :username, :email, :device, :created_at, :updated_at, :admin, :doctor
json.name @user.get_name()
json.url user_url(@user, format: :json)
json.avatar_url @user.avatar.url(:medium)
json.profile @user.profile

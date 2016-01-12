json.array!(@notifications) do |notification|
  json.extract! notification, :id, :user_id, :title, :detail, :notification_type, :recurrence_data, :form_name, :date, :dismissed_on
  json.url notification_url(notification, format: :json)
end

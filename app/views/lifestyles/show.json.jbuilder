json.extract! @lifestyle, :id, :user_id, :lifestyle_type_id, :source, :name, :details, :amount, :period_volume, :created_at, :updated_at, :title, :subtitle, :interval
json.name @lifestyle.lifestyle_type.name if @lifestyle.lifestyle_type
json.category @lifestyle.lifestyle_type.category if @lifestyle.lifestyle_type
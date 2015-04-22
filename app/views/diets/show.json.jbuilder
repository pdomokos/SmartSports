json.extract! @diet, :id, :user_id, :source,:type, :food_type_id, :name, :amount, :date, :calories, :carbs, :fat, :prot, :category, :created_at, :updated_at, :favourite
json.food_name @diet.food_type.name if @diet.type !='Smoke' and @diet.food_type
json.food_category @diet.food_type.category if @diet.type !='Smoke' and @diet.food_type
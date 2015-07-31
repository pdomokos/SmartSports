module Api::V1
  class FoodTypesController < ApiController
    respond_to :json

    def index
      type = params[:type]
      limit = params[:limit]
      food_types = FoodType.all
      if type && type=='drink'
        food_types = food_types.where("category = 'Ital'")
      elsif type && type=='food'
        food_types = food_types.where("category != 'Ital'")
      end
      if limit
        food_types = food_types.limit(limit)
      end
      render json: food_types
    end
  end
end

class FoodTypesController < ApplicationController
  respond_to :json

  def index
    id = params[:id]
    ftype = params[:type]
    limit = params[:limit]
    if id
      food_types = FoodType.where("id = '#{id}'")
    else
      if ftype == 'drink'
        food_types = FoodType.where("category = 'Ital'")
      elsif ftype=='food'
        food_types = FoodType.where("category != 'Ital'")
      end
    end
    if limit
      food_types = food_types.limit(limit)
    end
    render json: food_types
  end

end
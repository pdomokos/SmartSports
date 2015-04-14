class FoodTypesController < ApplicationController
  respond_to :json

  def index
    id = params[:id]
    type = params[:type]
    if id
      food_types = FoodType.where("id = '#{id}'")
    else
      if type
        food_types = FoodType.where("category = 'Ital'")
      else
        food_types = FoodType.where("category != 'Ital'")
      end
    end
    render json: food_types
  end

end
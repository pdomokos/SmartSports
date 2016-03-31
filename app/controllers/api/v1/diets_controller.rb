module Api::V1
  class DietsController < ApiController
    before_action :set_diet, only: [:update, :destroy]

    include DietsCommon

    def index
      user_id = params[:user_id]
      if current_resource_owner.id != user_id.to_i
        render json: nil, status: 403
        return
      end

      user = User.find(user_id)
      @diets = user.diets
      if params[:source]
        @diets = @diets.where(source: params[:source])
      end
      @diets = @diets.order(date: :desc)
      if params[:limit]
        @diets = @diets.limit( params[:limit].to_i )
      end

      render :template => '/diets/index.json'
    end
  end
end

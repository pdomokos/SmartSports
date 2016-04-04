module Api::V1
  class LifestylesController < ApiController
    before_action :set_lifestyle, only: [ :update, :destroy]

    include LifestylesCommon

    def index
      user_id = params[:user_id]
      if current_resource_owner.id != user_id.to_i
        render json: nil, status: 403
        return
      end

      user = User.find(user_id)
      @lifestyles = user.lifestyles
      if params[:source]
        @lifestyles = @lifestyles.where(source: params[:source])
      end
      @lifestyles = @lifestyles.order(start_time: :desc)
      if params[:limit]
        @lifestyles = @lifestyles.limit( params[:limit].to_i )
      end

      render :template => '/lifestyles/index.json'
    end
  end
end

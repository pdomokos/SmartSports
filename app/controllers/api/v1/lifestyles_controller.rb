module Api::V1
  class LifestylesController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!, only: [:index, :create]
    before_action :set_lifestyle, only: [ :update, :destroy]
    respond_to :json

    include LifestylesCommon

    def index
      lim = 10
      if params[:limit]
        lim = params[:limit].to_i
      end
      user_id = params[:user_id]

      if current_resource_owner.id != user_id.to_i
        render json: nil, status: 403
        return
      end

      user = User.find(user_id)
      lifestyles = user.lifestyles.where(source: @default_source).order(created_at: :desc).limit(lim)
      render json: lifestyles
    end
  end
end

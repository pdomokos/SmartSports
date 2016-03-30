module Api::V1
  class ActivitiesController < ApiController
    before_action :set_activity, only: [ :update, :destroy]

    include ActivitiesCommon

    def index
      user_id = params[:user_id]
      if current_resource_owner.id != user_id.to_i
        render json: nil, status: 403
        return
      end

      user = User.find(user_id)
      @activities = user.activities
      if params[:source]
        @activities = @activities.where(source: params[:source])
      end
      @activities = @activities.order(start_time: :desc)
      if params[:limit]
        @activities = @activities.limit(params[:limit].to_i)
      end

      render :template => "/activities/index.json"
    end

  end

end

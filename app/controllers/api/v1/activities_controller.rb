module Api::V1
  class ActivitiesController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!, only: [:index, :create]
    respond_to :json

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
      activities = user.activities.where(source: @default_source).order(start_time: :desc).limit(lim)
      render json: activities
    end

    def create
      user_id = params[:user_id]
      user = User.find(user_id)

      if current_resource_owner.id != user_id.to_i
        render json: { :ok => false}, status: 403
        return
      end

      activity = Activity.new(activity_params)
      activity.user_id = user.id
      if not activity.start_time
        activity.start_time = DateTime.now
      end
      if activity.save
        render json: { :ok => true, :id => activity.id }
      else
        render json: { :ok => false, :message =>  activity.errors.full_messages.to_sentence}, status: 400
      end
    end

    private
    def activity_params
      params.require(:activity).permit(:source, :activity, :group, :game_id, :start_time, :end_time, :steps, :duration, :distance, :calories, :manual)
    end

  end

end

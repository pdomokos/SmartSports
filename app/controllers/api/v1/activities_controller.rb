module Api::V1
  class ActivitiesController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!
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

    def update
      activity = Activity.find_by_id(params[:id])
      if activity.nil?
        render json: { :ok => false }, status: 400
        return
      end
      if activity.user_id != current_resource_owner.id
        render json: { :ok => false }, status: 403
        return
      end
      if activity.update(activity_params)
        render json: { :ok => true }
      else
        render json: {:ok => false, :msg => "Update failed" }, status: 400
      end
    end

    # DELETE /activities/1
    # DELETE /activities/1.json
    def destroy
      activity = Activity.find_by_id(params[:id])
      if activity.nil?
        render json: { :ok => false }, status: 400
        return
      end
      if activity.user_id != current_resource_owner.id
        render json: { :ok => false }, status: 403
        return
      end
      if activity.destroy
         render json: { :status => "OK", :msg => "Deleted successfully" }
      else
        render json: { :status => "NOK", :msg => "Delete errror" }, :status => 400
      end
    end

    private
    def activity_params
      params.require(:activity).permit(:source, :activity, :group, :game_id, :start_time, :end_time, :steps, :duration, :distance, :calories, :manual, :intensity, :favourite)
    end

  end

end

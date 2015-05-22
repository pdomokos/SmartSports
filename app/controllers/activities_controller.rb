class ActivitiesController < ApplicationController
  include ActivitiesCommon
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  # GET /activities
  # GET /activities.json
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

    favourites = params[:favourites]
    lang = params[:lang]
    if lang
      I18n.locale=lang
    end
    @activities = Activity.where("user_id = #{user_id}")
    if source
      @activities = @activities.where("source = '#{source}'")
    end
    if order and order=="desc"
      @activities = @activities.order(created_at: :desc)
    else
      @activities = @activities.order(created_at: :asc)
    end
    if limit and limit.to_i>0
      @activities = @activities.limit(limit)
    end

    if params[:year] and params[:month]
      year = params[:year].to_i
      month = params[:month].to_i
      numdays = Time.days_in_month(month, year)
      from = "#{year}-#{month}-01 00:00:00"
      to = "#{year}-#{month}-#{numdays} 23:59:59"
      @activities = @activities.where("date between '#{from}' and '#{to}'")
    end

    if favourites and favourites == "true"
      @activities = @activities.where(favourite: true)
    end

    @activities = @activities.order(:start_time)

    respond_to do |format|
      format.html
      format.json {render json: @activities}
      format.js
    end
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
  end

  # GET /activities/new
  def new
    @activity = Activity.new
    @user = current_user
  end

  # GET /activities/1/edit
  def edit
    @user = current_user
  end

  # POST /activities
  # POST /activities.json
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    @activity = user.activities.build(activity_params)
    if not @activity.start_time
      @activity.start_time = DateTime.now
    end
    actType = ActivityType.find_by_id(@activity.activity_type_id)
    if actType.nil?
      send_error_json(nil, "Invalid activity type", 404)
      return
    elsif not @activity.duration
      if @activity.start_time && @activity.end_time
        @activity.duration = ((@activity.end_time-@activity.start_time) / 60).to_i
      end
    end

    if @activity.duration
      @activity.calories = @activity.duration * actType.kcal / 10
      if @activity.intensity == 1.0
        @activity.calories = @activity.calories * 0.8
      elsif @activity.intensity == 3.0
        @activity.calories = @activity.calories * 1.2
      end
    end

    # respond_to do |format|
      if @activity.save
        send_success_json(@activity.id, {activity_name: @activity.activity_type.name})
      else
        send_error_json(nil, @activity.errors.full_messages.to_sentence, 400)
      end
    # end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_params
      params.require(:activity).permit(:source, :activity, :group, :game_id, :start_time, :end_time, :steps, :duration, :distance, :calories, :manual, :intensity, :favourite, :activity_type_id)
    end
end

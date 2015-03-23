class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]

  # GET /activities
  # GET /activities.json
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

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

    @activities = @activities.order(:start_time)

    respond_to do |format|
      format.html
      format.json {render json: @activities }
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
  end

  # GET /activities/1/edit
  def edit
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
    respond_to do |format|
      if @activity.save
        format.json { render json: {:status => "ok", :result => @activity} }
      else
        logger.error @activity.errors.full_messages.to_sentence
        format.json { render json: { :msg =>  @activity.errors.full_messages.to_sentence }, :status => 400 }
      end
    end
  end

  # PATCH/PUT /activities/1
  # PATCH/PUT /activities/1.json
  def update
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to @activity, notice: 'Activity was successfully updated.' }
        format.json { render json: { :status => "OK", :result => @activity } }
      else
        format.html { render :edit }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end


  end

  # DELETE /activities/1
  # DELETE /activities/1.json
  def destroy
    respond_to do |format|
      if @activity.destroy
        format.json { render json: { :status => "OK", :msg => "Deleted successfully" } }
      else
        format.json { render json: { :status => "NOK", :msg => "Delete errror" }, :status => 400 }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @activity = Activity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def activity_params
      params.require(:activity).permit(:source, :activity, :group, :game_id, :start_time, :end_time, :steps, :duration, :distance, :calories, :manual)
    end
end

class SummariesController < ApplicationController
  def new
    @activity = Summary.new
  end

  def create
     @activity = Summary.new(activity_params)
     respond_to do |format|
      if @activity.save
        format.html { redirect_to :controller => 'pages', :action => 'health' }
        format.json { render :show, status: :created, location: @activity }
      else
        format.html { redirect_to :controller => 'pages', :action => 'health' }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

   def index
    user_id = params[:user_id]
    source = params[:source]
    @activities = Summary.where("user_id = #{user_id}")
    if source
      @activities = @activities.where("source = '#{source}'")
    end
    if params[:from]
      from = params[:from]
      @activities = @activities.where("date > '#{from}'")
    elsif params[:year] and params[:month]
      year = params[:year].to_i
      month = params[:month].to_i
      numdays = Time.days_in_month(month, year)
      from = "#{year}-#{month}-01 00:00:00"
      to = "#{year}-#{month}-#{numdays} 23:59:59"
      @activities = @activities.where("date between '#{from}' and '#{to}'")
    end

    @activities = @activities.order(:date)
    activity_map = Hash.new { |hash, key| hash[key] = [] }
    for act in @activities do
      if !act['group'].nil?
        activity_map[act['group']].append(act)
      else
        activity_map['walking'].append(act)
      end
    end

    respond_to do |format|
      format.html
      format.json {render json: {:source => source, :activities =>activity_map } }
    end
   end

  private

  def activity_params
    params.require(:summary).permit(:user_id, :source, :activity, :group, :distance, :total_duration, :date, :steps)
  end
end

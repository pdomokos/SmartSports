class ActivitiesController < ApplicationController
  def index
    user_id = params[:user_id]

    @activities = Activity.where("user_id = #{user_id}").order(:date)
    if params[:year] and params[:month]
      year = params[:year].to_i
      month = params[:month].to_i
      numdays = Time.days_in_month(month, year)
      from = "#{year}-#{month}-01 00:00:00"
      to = "#{year}-#{month}-numdays 23:59:59"
      @activities = @activities.where("date between '#{from}' and '#{to}'")
    end

    activity_map = Hash.new { |hash, key| hash[key] = [] }
    for act in @activities do
      if act['group'] != 'transport'
        activity_map[act['group']].append(act)
      end
    end

    respond_to do |format|
      format.html
      format.json {render json: activity_map}
    end
  end
end

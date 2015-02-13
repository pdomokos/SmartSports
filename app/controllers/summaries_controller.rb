class SummariesController < ApplicationController

   def index
    user_id = params[:user_id]
    source = params[:source]
    @summaries = Summary.where("user_id = #{user_id}")
    if source
      @summaries = @summaries.where("source = '#{source}'")
    end

    if params[:start]
      startday = params[:start]
      @summaries = @summaries.where("date > '#{startday}'")
    elsif params[:year] and params[:month]
      year = params[:year].to_i
      month = params[:month].to_i
      numdays = Time.days_in_month(month, year)
      startday = "#{year}-#{month}-01 00:00:00"
      to = "#{year}-#{month}-#{numdays} 23:59:59"
      @summaries = @summaries.where("date between '#{startday}' and '#{to}'")
    end

    @summaries = @summaries.order(:date)

    if params[:daily] and params[:daily] == "true"
      keys = ["walking", "running", "cycling", "sleep"]

      result = []
      cd
    else
      result = Hash.new { |hash, key| hash[key] = [] }
      for act in @summaries do
        if !act['group'].nil?
          result[act['group']].append(act)
        else
          result['walking'].append(act)
        end
      end
    end
    respond_to do |format|
      format.html
      format.json {render json: result }
    end
   end

  private

  def activity_params
    params.require(:summary).permit(:user_id, :source, :activity, :group, :distance, :total_duration, :date, :steps)
  end
end

class SummaryController < ApplicationController

  def index
    user_id = params[:user_id]
    user = User.find(user_id)
    summary = {}

    if user
      summary = {
        :time => '2015-01-07 11:19',
        :steps => 1442,
        :cycling => 16.5,
        :running => 2.3,
        :calories => 424,
        :distance => 4.3,
        :activity =>  1241,
        :profile => (1..24).collect {|it| { 'time' => it, 'activity' => (rand()*60).round()}}
      }
    end

    respond_to do |format|
      format.json {render json: summary.to_json}
    end
  end
end

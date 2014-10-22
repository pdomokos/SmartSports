class ActivitiesController < ApplicationController
  def index
    user_id = params[:user_id]
    user = User.find(user_id)
    @activities = user.activities

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

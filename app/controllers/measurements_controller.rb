class MeasurementsController < ApplicationController
  def index
    user_id = params[:user_id]
    user = User.find(user_id)
    @measurements = user.measurements

    respond_to do |format|
      format.html
      format.json {render json: @measurements}
    end
  end
end

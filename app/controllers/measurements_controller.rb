class MeasurementsController < ApplicationController
  def new
    @measurement = Measurement.new
  end

  def create
    @measurement = Measurement.new(measurement_params)

    respond_to do |format|
      if @measurement.save
        format.html { redirect_to :controller => 'pages', :action => 'health' }
        format.json { render :show, status: :created, location: @measurement }
      else
        format.html { redirect_to :controller => 'pages', :action => 'health' }
        format.json { render json: @measurement.errors, status: :unprocessable_entity }
      end
    end
  end

  def index
    user_id = params[:user_id]
    user = User.find(user_id)
    @measurements = user.measurements

    respond_to do |format|
      format.html
      format.json {render json: @measurements}
    end

  end

  def show
  end

  private

  def measurement_params
    params.require(:measurement).permit(:user_id, :source, :systolicbp, :diastolicbp, :pulse, :date)
  end

end

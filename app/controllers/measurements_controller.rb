class MeasurementsController < ApplicationController
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]
  def new
    @measurement = Measurement.new
  end

  def create
    @measurement = Measurement.new(measurement_params)

    respond_to do |format|
      if @measurement.save
        format.html { redirect_to user_measurements_path(@measurement.user) }
        format.json { render :show, status: :created, location: @measurement }
      else
        format.html { redirect_to user_measurements_path(@measurement.user) }
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

  # DELETE /measurements/1
  # DELETE /measurements/1.json
  def destroy
    user = @measurement.user
    @measurement.destroy
    respond_to do |format|
      format.html { redirect_to user_measurements_url(user), notice: 'Measurement was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_measurement
    @measurement = Measurement.find(params[:id])
  end

  def measurement_params
    params.require(:measurement).permit(:user_id, :source, :systolicbp, :diastolicbp, :pulse, :date)
  end

end

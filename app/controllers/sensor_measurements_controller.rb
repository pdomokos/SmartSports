class SensorMeasurementsController < ApplicationController
  def index
    user = User.find(params[:user_id])
    @sensor_measurements = user.sensor_measurements.order(start_time: :desc)
  end
  def show
    id =  params[:id]
    sensor = SensorMeasurement.where(id: id)
    @sensor_measurement = nil
    if sensor.length
      @sensor_measurement = sensor[0]
    end
  end

  def edit
    @user = User.find(params[:user_id])
    @sensor_measurement = SensorMeasurement.find(params[:id])
  end

  # PATCH/PUT /lifestyles/1
  # PATCH/PUT /lifestyles/1.json
  def update
    @sensor_measurement = SensorMeasurement.find(params[:id])
    respond_to do |format|
      if @sensor_measurement.update(sensor_params)
        format.html { redirect_to user_sensor_measurement_url(@sensor_measurement.user, @sensor_measurement), notice: 'Sensor_measurement was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  private
  def sensor_params
    params.require(:sensor_measurement).permit(:group, :duration, :favourite, :sensors)
  end

end
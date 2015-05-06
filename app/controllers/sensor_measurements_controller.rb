class SensorMeasurementsController < ApplicationController
  def index
    user = User.find(params[:user_id])
    @sensor_measurements = user.sensor_measurements
  end
  def show
    id =  params[:id]
    sensor = SensorMeasurement.where(id: id)
    @sensor_measurement = nil
    if sensor.length
      @sensor_measurement = sensor[0]
    end
  end
end
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
    summary = (params[:summary] and params[:summary] == "true")
    start = params[:start]
    user = User.find(user_id)

    @measurements = user.measurements
    if summary
      puts "summary"
      daily_data = Hash.new { |h,k| h[k] = [] }
      for m in @measurements
        k = m.date.strftime("%F")
        daily_data[k] << m
      end

      days = daily_data.keys().sort()
      result = []
      for day in days
        daily = daily_data[day]
        temp = {"date" => day, "systolicbp"=>0, "diastolicbp"=>0, "pulse"=>0, "SPO2"=>0}
        for meas in ["systolicbp", "diastolicbp", "pulse", "SPO2"]
          values = daily.select { |d| !d[meas].nil?}.map { |d| d[meas] }
          num = values.length
          if num > 0
            temp[meas] = (values.inject {|sum, curr| sum+curr}.to_f/num).round
          else
            temp[meas] = nil
          end
        end
        result << temp
      end

      respond_to do |format|
        format.json {render json: result}
      end
    else
      if start
        @measurements = @measurements.where("date >= '"+start+"'")
      end
      respond_to do |format|
        format.html
        format.json {render json: @measurements}
      end
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

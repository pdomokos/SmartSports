class MeasurementsController < ApplicationController
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]
  def new
    @measurement = Measurement.new
  end

  def create
    @measurement = Measurement.new(measurement_params)
    @measurement.date = DateTime.now

    respond_to do |format|
      if @measurement.save
        format.json { render json: { :status => "OK", :msg => "Saved successfully", :result => @measurement } }
      else
        format.json { render json: { :status => "NOK", :msg => "Save error" } }
      end
    end
  end

  # PATCH/PUT /measurements/1
  # PATCH/PUT /measurements/1.json
  def update
    respond_to do |format|
      if @measurement.update(measurement_params)
        format.json { render json: { :status => "OK", :msg => "Updated successfully", :result => @measurement } }
      else
        format.json { render json: { :status => "NOK", :msg => "Update errror" } }
      end
    end
  end

  def index
    user_id = params[:user_id]
    summary = (params[:summary] and params[:summary] == "true")
    start = params[:start]
    user = User.find(user_id)
    hourly = params[:hourly]

    @measurements = user.measurements
    if summary
      if start
        @measurements = @measurements.where("date >= '#{start}'")
      end

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
    elsif hourly
      result = []
      data = user.measurements.collect{|it| [it.date.hour, it[hourly]]}.select{|it| !it[1].nil?}

      hash = Hash.new{ |h,k| h[k] = []}
      data.each do |it|
        hash[it[0]] << it[1]
      end

      hours = hash.keys().sort()
      hours.each do |hour|
        # puts "#{hour} - #{hash[hour].sort()}"
        if hash[hour] and hash[hour].size!=0
          stats = get_stats(hash[hour])
          result << {
              :hour => hour,
              :min => hash[hour].min,
              :max => hash[hour].max,
              :avg => stats[:avg],
              :median => stats[:median],
              :lower => stats[:lower],
              :upper => stats[:upper],
              :sd => stats[:sd],
              :size => hash[hour].size
          }
        end
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

  def get_stats(arr)
    len = arr.size
    if len == 0
      return nil
    end
    result = {}
    avg = arr.reduce{|c, s| c+s}/len.to_f
    result[:avg] = avg
    arr.sort!
    med_index = len/2
    if (len>1)
      med_index -= 1
    end
    puts "#{len} #{med_index}"

    result[:median] = arr[med_index]
    result[:lower] = arr[(len*0.25).floor()]
    result[:upper] = arr[(len*0.75).floor()]
    result[:sd] = Math.sqrt(arr.reduce{|s, c| s+(c-avg)**2}/len.to_f)
    return result
  end

  def show
  end

  # DELETE /measurements/1
  # DELETE /measurements/1.json
  def destroy
    # user = @measurement.user
    # @measurement.destroy
    # respond_to do |format|
    #   format.html { redirect_to user_measurements_url(user), notice: 'Measurement was successfully destroyed.' }
    #   format.json { head :no_content }
    # end
    respond_to do |format|
      if @measurement.destroy
        format.json { render json: { :status => "OK", :msg => "Deleted successfully" } }
      else
        format.json { render json: { :status => "NOK", :msg => "Delete errror" } }
      end
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

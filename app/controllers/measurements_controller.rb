class MeasurementsController < ApplicationController
  include MeasurementsCommon
  skip_before_filter :require_login, only: [:create]
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]
  include SaveClickRecord

  def new
    @measurement = Measurement.new
  end

  def create
    user_id = params[:user_id].to_i
    if user_id != current_user.id
      render json: { :msg => "Unauthorized" }, :status => 401
      return
    end
    par = measurement_params
    par.merge!(:user_id => user_id)

    @measurement = Measurement.new(par)
    if @measurement.date.nil?
      @measurement.date = DateTime.now
    end

    respond_to do |format|
      if @measurement.save
        save_click_record(current_user.id, true, nil)
        format.json { render json: { :status => "OK", :msg => "Saved successfully", :id => @measurement.id, :msg=> create_success_message() } }
      else
        msg =  @measurement.errors.full_messages.to_sentence+"\n"
        save_click_record(current_user.id, false, @measurement.errors.full_messages.to_sentence)
        format.json { render json: { :msg => msg }, :status => 400 }
      end
    end
  end

  def load_recent
    user_id = params[:user_id]
    user = User.find(user_id)
    @measurements = user.measurements.where(source: source).order(date: :desc).limit(4)
    respond_to do |format|
      format.js
    end
  end

  def index

    user_id = params[:user_id]
    summary = (params[:summary] and params[:summary] == "true")
    start = params[:start]
    user = User.find(user_id)
    hourly = params[:hourly]
    source = params[:source]
    order = params[:order]
    limit = params[:limit]
    favourites = params[:favourites]
    lang = params[:lang]

    if lang
      I18n.locale=lang
    end
    @measurements = user.measurements
    if start
      @measurements = @measurements.where("date >= '#{start}'")
    end
    if source
      @measurements = @measurements.where(source: source)
    end
    if order
      @measurements = @measurements.order(created_at: :desc)
    else
      @measurements = @measurements.order(created_at: :asc)
    end
    if limit
      @measurements = @measurements.limit(limit)
    end
    if favourites and favourites == "true"
      @measurements = @measurements.where(favourite: true)
    end

    if summary
      daily_data = Hash.new { |h,k| h[k] = [] }
      for m in @measurements
        if m.date
          k = m.date.strftime("%F")
          daily_data[k] << m
        end
      end

      days = daily_data.keys().sort()
      result = []
      for day in days
        daily = daily_data[day]
        temp = {"date" => day, "systolicbp"=>0, "diastolicbp"=>0, "pulse"=>0, "SPO2"=>0, "blood_sugar" => nil, "weight" => nil, "waist" => nil}
        for meas in ["systolicbp", "diastolicbp", "pulse", "SPO2", "blood_sugar", "weight", "waist"]
          values = daily.select { |d| !d[meas].nil?}.map { |d| d[meas] }
          num = values.length
          if num > 0
            temp[meas] = (values.inject {|sum, curr| sum+curr}.to_f/num)
          else
            temp[meas] = nil
          end
        end
        result << temp
      end

      respond_to do |format|
        format.json {render json: result}
      end
    else if hourly
      result = []
      data = user.measurements.collect{|it| [it.date.hour, it[hourly]]}.select{|it| !it[1].nil?}

      hash = Hash.new{ |h,k| h[k] = []}
      data.each do |it|
        hash[it[0]] << it[1]
      end

      hours = hash.keys().sort()
      hours.each do |hour|
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
      respond_to do |format|
        format.html
        format.json {render json: @measurements}
        format.js
      end
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
    result[:median] = arr[med_index]
    result[:lower] = arr[(len*0.25).floor()]
    result[:upper] = arr[(len*0.75).floor()]
    result[:sd] = Math.sqrt(arr.reduce{|s, c| s+(c-avg)**2}/len.to_f)
    return result
  end

  def show
  end

  private

  def set_measurement
    @measurement = Measurement.find(params[:id])
  end

  def measurement_params
    params.require(:measurement).permit(:source, :systolicbp, :diastolicbp, :pulse, :blood_sugar, :weight, :waist, :date, :meas_type, :favourite)
  end

  def create_success_message()
    if @measurement.meas_type == 'blood_pressure'
      sys = @measurement.systolicbp || '-'
      dia = @measurement.diastolicbp|| '-'
      pulse = @measurement.pulse|| '-'
      return "Blood pressure #{sys}/#{dia}/#{pulse} created"
    end
    if @measurement.meas_type == 'blood_sugar'
      return "Blood glucose measurement #{@measurement.blood_sugar} created"
    end
    if @measurement.meas_type == 'weight'
      return "Weight measurement #{@measurement.weight} created"
    end
    if @measurement.meas_type == 'waist'
      return "Waist circumfence measurement #{@measurement.waist} created"
    end
  end
end

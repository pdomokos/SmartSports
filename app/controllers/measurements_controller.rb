require 'csv'
class MeasurementsController < ApplicationController
  before_action :set_measurement, only: [:show, :edit, :update, :destroy]
  before_action :check_owner_or_doctor
  include MeasurementsCommon

  def new
    @measurement = Measurement.new
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
    meas_type = params[:meas_type]
    summary = (params[:summary] and params[:summary] == "true")
    start = params[:start]
    user = User.find(user_id)
    hourly = params[:hourly]
    source = params[:source]
    order = params[:order]
    limit = params[:limit]
    favourites = params[:favourites]
    lang = params[:lang]
    table = params[:table]

    @measurements = user.measurements
    if start
      @measurements = @measurements.where("date >= '#{start}'")
    end
    if source
      @measurements = @measurements.where(:source => [source, 'demo'])
    end
    if meas_type
      @measurements = @measurements.where(meas_type: meas_type)
    end
    if order
      @measurements = @measurements.order(date: :desc)
    else
      @measurements = @measurements.order(date: :asc)
    end
    if limit
      @measurements = @measurements.limit(limit)
    end
    if favourites and favourites == "true"
      @measurements = @measurements.where(favourite: true)
    end

    if summary
      daily_data = Hash.new { |h, k| h[k] = [] }
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
        aggr = {"date" => day, "systolicbp" => 0, "diastolicbp" => 0, "pulse" => 0, "SPO2" => 0, "blood_sugar" => nil, "weight" => nil, "waist" => nil}
        for meas in ["systolicbp", "diastolicbp", "pulse", "SPO2", "blood_sugar", "weight", "waist"]
          values = daily.select { |d| !d[meas].nil? }.map { |d| d[meas] }
          num = values.length
          if num > 0
            aggr[meas] = (values.inject { |sum, curr| sum+curr }.to_f/num)
          else
            aggr[meas] = nil
          end
        end
        result << aggr
      end

      respond_to do |format|
        format.json { render json: result }
      end
    elsif hourly
      result = []
      data = user.measurements.collect { |it| [it.date.hour, it[hourly]] }.select { |it| !it[1].nil? }

      hash = Hash.new { |h, k| h[k] = [] }
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
        format.json { render json: result }
      end
    elsif table
      @measurements = get_table_data(@measurements, lang)

      respond_to do |format|
        format.json { render json: @measurements }
      end

    else
      respond_to do |format|
        format.html
        format.json { render json: @measurements }
        format.csv { send_data to_csv(@measurements, {}, lang).encode("iso-8859-2"), :type => 'text/csv; charset=iso-8859-2; header=present' }
        format.js
      end
    end
  end

  def get_stats(arr)
    len = arr.size
    if len == 0
      return nil
    end
    result = {}
    avg = arr.reduce { |c, s| c+s }/len.to_f
    result[:avg] = avg
    arr.sort!
    med_index = len/2
    if (len>1)
      med_index -= 1
    end
    result[:median] = arr[med_index]
    result[:lower] = arr[(len*0.25).floor()]
    result[:upper] = arr[(len*0.75).floor()]
    result[:sd] = Math.sqrt(arr.reduce { |s, c| s+(c-avg)**2 }/len.to_f)
    return result
  end

  def show
  end

  private

  def get_table_data(data, lang)
    tableData = []
    if lang == 'en'
      stressList = (I18n.t 'stressList', :locale => :en).split(',')
      bgTimeList = (I18n.t 'bgTimeList', :locale => :en).split(',')
      stress_str = (I18n.t 'stress', :locale => :en)
    else
      stressList = (I18n.t 'stressList', :locale => :hu).split(',')
      bgTimeList = (I18n.t 'bgTimeList', :locale => :hu).split(',')
      stress_str = (I18n.t 'stress', :locale => :hu)
    end
    for item in data
      bg_time=''
      stress=''
      if item.meas_type == 'blood_pressure'
        if item.systolicbp
          value = item.systolicbp.to_s
        end
        if value != ""
          value = value + "/"
        end
        if item.diastolicbp
          value = value + item.diastolicbp.to_s
        end
        if value != ""
          value = value + " "
        end
        if item.pulse
          value = value + item.pulse.to_s
        end
      elsif item.meas_type == 'blood_sugar'
        value = item.blood_sugar.to_s + " mmol/L"
        bg_time = bgTimeList[item.blood_sugar_time]
        stress = stressList[item.stress_amount]+' '+stress_str.downcase
      elsif item.meas_type == 'weight'
        value = item.weight.to_s + " kg"
      elsif item.meas_type == 'waist'
        value = item.waist.to_s + " cm"
      end

      if lang=='en'
        mType = ((I18n.t item.meas_type, :locale => :en))
      else
        mType = ((I18n.t item.meas_type, :locale => :hu))
      end
      row = {"date" => item.date, "type" => mType, "value" => value, "property1" => bg_time, "property2" => stress}
      tableData.push(row)
    end
    return tableData
  end


  def to_csv(data, options={}, lang = '')
    data=get_table_data(data, lang)
    CSV.generate(options) do |csv|
      if lang == "hu"
        csv << [((I18n.t 'meas_header_values', :locale => :hu).split(' '))[0], ((I18n.t 'meas_header_values', :locale => :hu).split(' '))[1], ((I18n.t 'meas_header_values', :locale => :hu).split(' '))[2], ((I18n.t 'meas_header_values', :locale => :hu).split(' '))[3], ((I18n.t 'meas_header_values', :locale => :hu).split(' '))[4]]
      elsif lang == "en"
        csv << [((I18n.t 'meas_header_values', :locale => :en).split(' '))[0], ((I18n.t 'meas_header_values', :locale => :en).split(' '))[1], ((I18n.t 'meas_header_values', :locale => :en).split(' '))[2], ((I18n.t 'meas_header_values', :locale => :en).split(' '))[3], ((I18n.t 'meas_header_values', :locale => :en).split(' '))[4]]
      end
      data.each do |item|
        csv << [item['date'].strftime("%Y-%m-%d %H:%M"), item['type'], item['value'], item['property1'], item['property2']]
      end
    end
  end

end

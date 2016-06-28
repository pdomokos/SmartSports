class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy]
  before_action :check_owner_or_doctor

  include ActivitiesCommon

  # GET /activities
  # GET /activities.json
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

    lang = params[:lang]

    favourites = params[:favourites]

    table = params[:table]

    @activities = Activity.where("user_id = #{user_id}")
    if source
      @activities = @activities.where("source = '#{source}'")
    end
    if order and order=="desc"
      @activities = @activities.order(start_time: :desc)
    end

    if limit and limit.to_i>0
      @activities = @activities.limit(limit)
    end

    if params[:year] and params[:month]
      year = params[:year].to_i
      month = params[:month].to_i
      numdays = Time.days_in_month(month, year)
      from = "#{year}-#{month}-01 00:00:00"
      to = "#{year}-#{month}-#{numdays} 23:59:59"
      @activities = @activities.where("date between '#{from}' and '#{to}'")
    elsif params[:date]
      date = params[:date]
      @activities = @activities.where("start_time between '#{date} 00:00:00' and '#{date} 23:59:59'")
    end

    if favourites and favourites == "true"
      @activities = @activities.where(favourite: true)
    end

    if table
      @activities = get_table_data(@activities, lang)
    end

    respond_to do |format|
      format.html
      format.json {render json: @activities}
      format.csv { send_data to_csv(@activities,{}, lang).encode("iso-8859-2"), :type => 'text/csv; charset=iso-8859-2; header=present' }
      format.js
    end
  end

  # GET /activities/1
  # GET /activities/1.json
  def show
  end

  private

  def get_table_data(data, lang)
    tableData = []
    activityTypeList = ActivityType.all

    for item in data
      name_key = activityTypeList.where(id: item.activity_type_id).first.name

      if lang=='en'
        name = DB_EN_CONFIG['activities'][name_key]
        if item.intensity != nil && item.intensity
          intensities = ((I18n.t 'intensities', :locale => :en).split(' '))[item.intensity]
        end
      else
        name = DB_HU_CONFIG['activities'][name_key]
        if item.intensity != nil && item.intensity
          intensities = ((I18n.t 'intensities', :locale => :hu).split(' '))[item.intensity]
        end
      end
      row = {"date"=>item.start_time, "name"=>name, "intensity"=>intensities ,"duration"=>item.duration, "calories"=>item.calories.round(2)}
      tableData.push(row)
    end
    return tableData
  end

  def to_csv(data, options={}, lang = '')
    data=get_table_data(data,lang)
    CSV.generate(options) do |csv|
      if lang == "hu"
        csv << [((I18n.t 'header_values', :locale => :hu).split(','))[0], ((I18n.t 'header_values', :locale => :hu).split(','))[1], ((I18n.t 'header_values', :locale => :hu).split(','))[2], ((I18n.t 'header_values', :locale => :hu).split(','))[3], ((I18n.t 'header_values', :locale => :hu).split(','))[4]]
      elsif lang == "en"
        csv << [((I18n.t 'header_values', :locale => :en).split(','))[0], ((I18n.t 'header_values', :locale => :en).split(','))[1], ((I18n.t 'header_values', :locale => :en).split(','))[2], ((I18n.t 'header_values', :locale => :en).split(','))[3], ((I18n.t 'header_values', :locale => :en).split(','))[4]]
      end
      data.each do |item|
        csv << [item['date'].strftime("%Y-%m-%d %H:%M"),item['name'],item['intensity'],item['duration'],item['calories']]
      end
    end
  end
end

module LifestylesCommon
  # POST /lifestyles
  # POST /lifestyles.json
  def create
    user = User.find(params[:user_id])
    name = params['lifestyle']['name']
    params[:lifestyle].delete :name

    lifestyle = user.lifestyles.build(lifestyle_params)
    lt = LifestyleType.where(name: name).first
    if lt.nil?
      send_error_json(name, "Invalid lifestyle type", 404)
      return
    end
    lifestyle.lifestyle_type = lt


    if not lifestyle.start_time
      lifestyle.start_time = DateTime.now
    end
    # This is to add the time to stress and illness start_time, so the ordering will not be mixed for today
    if lifestyle.start_time.today?
      new_time = Time.zone.now
      if lt.category=='stress' or lt.category=='illness' or lt.category=='period'
        param_time = lifestyle.start_time
        lifestyle.start_time = DateTime.new(param_time.year, param_time.month, param_time.day,
                                            new_time.hour, new_time.min, 0, new_time.zone)
      end
      if lt.category=='illness' or lt.category=='period'
        param_time = lifestyle.end_time
        lifestyle.end_time = DateTime.new(param_time.year, param_time.month, param_time.day,
                                            new_time.hour, new_time.min, 0, new_time.zone)
      end
    end

    if lifestyle.save
      send_success_json(lifestyle.id, {name: lifestyle.lifestyle_type.name,
                                        category: lifestyle.lifestyle_type.category})
    else
      send_error_json(nil, lifestyle.errors.full_messages.to_sentence, 400)
    end
  end

  # PATCH/PUT /lifestyles/1
  # PATCH/PUT /lifestyles/1.json
  def update
    if params['lifestyle'] && params['lifestyle']['lifestyle_type_name']
      lt = LifeStyleType.where(name: params['lifestyle']['lifestyle_type_name']).first
      if lt.nil?
        send_error_json(@lifestyle.id,  "Invalid lifestyle type", 404)
        return
      end
      @lifestyle.lifestyle_type_id = lt.id

    end

    if @lifestyle.update(lifestyle_params)
      send_success_json(@lifestyle.id, {})
    else
      send_error_json(@lifestyle.id, @lifestyle.errors.full_messages.to_sentence, 400)
    end
  end

  # DELETE /lifestyles/1
  # DELETE /lifestyles/1.json
  def destroy
    if @lifestyle.destroy
      send_success_json(@lifestyle.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@lifestyle.id, "Delete failed", 400)
    end
  end

  private
  def get_lifestyles()
    user_id = params[:user_id]
    user = User.find_by_id(user_id)
    lang = params[:lang]
    table = params[:table]

    @lifestyles = user.lifestyles
    if params[:source]
      @lifestyles = @lifestyles.where(source: params[:source])
    end
    @lifestyles = @lifestyles.order("start_time desc, id desc")
    if params[:limit]
      @lifestyles = @lifestyles.limit( params[:limit].to_i )
    end

    if table
      @lifestyles = get_table_data(@lifestyles, lang)
    end

  end

  def get_table_data(data, lang)
    tableData = []
    if lang=='en'
      illnessList = (I18n.t 'illnessList', :locale => :en).split(',')
      sleepList = (I18n.t 'sleepList', :locale => :en).split(',')
      stressList = (I18n.t 'stressList', :locale => :en).split(',')
      painList = (I18n.t 'painList', :locale => :en).split(',')
      periodPainList = (I18n.t 'periodPainList', :locale => :en).split(',')
      periodVolumeList = (I18n.t 'periodVolumeList', :locale => :en).split(',')
    else
      illnessList = (I18n.t 'illnessList', :locale => :hu).split(',')
      sleepList = (I18n.t 'sleepList', :locale => :hu).split(',')
      stressList = (I18n.t 'stressList', :locale => :hu).split(',')
      painList = (I18n.t 'painList', :locale => :hu).split(',')
      periodPainList = (I18n.t 'periodPainList', :locale => :hu).split(',')
      periodVolumeList = (I18n.t 'periodVolumeList', :locale => :hu).split(',')
    end
    for item in data
      ltype = LifestyleType.find(item.lifestyle_type_id)

      if lang=='en'
        category = DB_EN_CONFIG['categories'][ltype.category]
        name = DB_EN_CONFIG['lifestyle'][ltype.category][ltype.name]
      else
        category = DB_HU_CONFIG['categories'][ltype.category]
        name = DB_HU_CONFIG['lifestyle'][ltype.category][ltype.name]
      end
      property1 = ""
      property2 = ""
      if ltype.category == 'illness'
        property1 = illnessList[item.amount]
        property2 = item.details
      elsif ltype.category == 'pain'
        property1 = painList[item.amount]
        property2 = item.details
      elsif ltype.category == 'period'
        property1 = periodPainList[item.amount]
        property2 = periodVolumeList[item.period_volume]
        name = ""
      elsif ltype.category == 'sleep'
        property1 = sleepList[item.amount]
        name = ""
      elsif ltype.category == 'stress'
        property1 = stressList[item.amount]
        name = ""
      end

      row = {"id"=>item.id, "date"=>item.start_time, "category"=>category, "type"=>name ,"property1"=>property1, "property2"=>property2}
      tableData.push(row)
    end
    return tableData
  end

  def to_csv(data, options={}, lang = '')
    data=get_table_data(data,lang)
    CSV.generate(options) do |csv|
      if lang == "hu"
        csv << [((I18n.t 'lifestyle_header_values', :locale => :hu).split(','))[0], ((I18n.t 'lifestyle_header_values', :locale => :hu).split(','))[1], ((I18n.t 'lifestyle_header_values', :locale => :hu).split(','))[2], ((I18n.t 'lifestyle_header_values', :locale => :hu).split(','))[3], ((I18n.t 'lifestyle_header_values', :locale => :hu).split(','))[4]]
      elsif lang == "en"
        csv << [((I18n.t 'lifestyle_header_values', :locale => :en).split(','))[0], ((I18n.t 'lifestyle_header_values', :locale => :en).split(','))[1], ((I18n.t 'lifestyle_header_values', :locale => :en).split(','))[2], ((I18n.t 'lifestyle_header_values', :locale => :en).split(','))[3], ((I18n.t 'lifestyle_header_values', :locale => :en).split(','))[4]]
      end
      data.each do |item|
        csv << [item['date'].strftime("%Y-%m-%d %H:%M"),item['category'],item['type'], item['property1'], item['property2']]
      end
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_lifestyle
    @lifestyle = Lifestyle.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def lifestyle_params
    params.require(:lifestyle).permit(:user_id, :source, :name, :details, :amount, :period_volume, :start_time, :end_time, :favourite)
  end
end
class MedicationsController < ApplicationController
  include MedicationsCommon

  def show
    user = User.find(params[:user_id])
    @medication = user.medications.where(id: params[:id]).first
  end

  def index
    user_id = params[:user_id]

    source = params[:source]
    order = params[:order]
    limit = params[:limit]
    favourites = params[:favourites]
    table = params[:table]
    lang = params[:lang]

    u = User.find(user_id)
    @medications = u.medications

    if source and source !=""
      @medications = @medications.where(source: source)
    end
    if order and order=="desc"
      @medications = @medications.order(date: :desc)
    else
      @medications = @medications.order(date: :asc)
    end
    if limit and limit.to_i>0
      @medications = @medications.limit(limit)
    end
    @user = u

    if favourites and favourites == "true"
      @medications = @medications.where(favourite: true)
    end

    if table
      @medications = get_table_data(@medications, lang)
    end

    respond_to do |format|
      format.json {render json: @medications}
      format.csv { send_data to_csv(@medications, {}, lang).encode("iso-8859-2"), :type => 'text/csv; charset=iso-8859-2; header=present' }
      format.js
    end
  end

  private

  def get_table_data(data, lang)
    tableData = []
    for item in data
      if item.medication_type_id
        type = MedicationType.find(item.medication_type_id)
        name = type.title
      elsif item.custom_medication_type_id
        type = CustomMedicationType.find(item.custom_medication_type_id)
        name = type.name
      end
      if type.category == 'oral'
        category = 'drugs'
      elsif type.category == 'drugs_en'
        category = 'drugs'
      elsif type.category == 'insulin'
        category = 'insulin'
      elsif type.category == 'insulin_en'
        category = 'insulin'
      elsif type.category == 'custom_drug'
        category = 'drugs'
      elsif type.category == 'custom_insulin'
        category = 'insulin'
      else
        category = ""
        name = ""
      end
      if lang=='en'
        if category == 'drugs'
          category = ((I18n.t 'drugs', :locale => :en))
        elsif category == 'insulin'
          category = ((I18n.t 'insulin', :locale => :en))
        end
      else
        if category == 'drugs'
          category = ((I18n.t 'drugs', :locale => :hu))
        elsif category == 'insulin'
          category = ((I18n.t 'insulin', :locale => :hu))
        end
      end

      row = {"date"=>item.date, "category"=>category, "name"=>name ,"amount"=>item.amount}
      tableData.push(row)
    end
    return tableData
  end

  def to_csv(data, options={}, lang = '')
    data=get_table_data(data,lang)
    CSV.generate(options) do |csv|
      if lang == "hu"
        csv << [((I18n.t 'medication_header_values', :locale => :hu).split(','))[0], ((I18n.t 'medication_header_values', :locale => :hu).split(','))[1], ((I18n.t 'medication_header_values', :locale => :hu).split(','))[2], ((I18n.t 'medication_header_values', :locale => :hu).split(','))[3]]
      elsif lang == "en"
        csv << [((I18n.t 'medication_header_values', :locale => :en).split(','))[0], ((I18n.t 'medication_header_values', :locale => :en).split(','))[1], ((I18n.t 'medication_header_values', :locale => :en).split(','))[2], ((I18n.t 'medication_header_values', :locale => :en).split(','))[3]]
      end
      data.each do |item|
        csv << [item['date'].strftime("%Y-%m-%d %H:%M"),item['category'],item['name'],item['amount']]
      end
    end
  end

end

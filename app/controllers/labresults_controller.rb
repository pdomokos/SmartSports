class LabresultsController < ApplicationController
  include LabresultsCommon
  include SaveClickRecord
  before_action :set_var
  def index
    user_id = params[:user_id]

    order = params[:order]
    limit = params[:limit]
    lang = params[:lang]
    table = params[:table]

    @labresults = Labresult.where("user_id = #{user_id}")

    if order and order=="desc"
      @labresults = @labresults.order(date: :desc)
    else
      @labresults = @labresults.order(date: :asc)
    end
    if limit and limit.to_i>0
      @labresults = @labresults.limit(limit)
    end

    if table
      @labresults = get_table_data(@labresults, lang)
    end

    respond_to do |format|
      format.json {render json: @labresults}
      format.csv { send_data to_csv(@labresults,{}, lang).encode("iso-8859-2"), :type => 'text/csv; charset=iso-8859-2; header=present' }
      format.js
    end
  end

  private

  def get_table_data(data, lang)
    tableData = []
    for item in data
      category=item.category
      value=""
      if category=='ketone'
        if lang=='en'
          category=DB_EN_CONFIG['categories']['ketone']
          value=DB_EN_CONFIG['labresult']['ketone'][item.labresult_type_name]
        else
          category=DB_HU_CONFIG['categories']['ketone']
          value=DB_HU_CONFIG['labresult']['ketone'][item.labresult_type_name]
        end
      elsif category=='hba1c'
        value=item.hba1c
      elsif category=='ldl_chol'
        value=item.ldl_chol
      elsif category=='egfr_epi'
        value=item.egfr_epi
      end

      row = {"date"=>item.date, "category"=>category,"value"=>value}
      tableData.push(row)
    end
    return tableData
  end

  def to_csv(data, options={}, lang = '')
    data=get_table_data(data,lang)
    CSV.generate(options) do |csv|
      if lang == "hu"
        csv << [((I18n.t 'labresult_header_values', :locale => :hu).split(','))[0], ((I18n.t 'labresult_header_values', :locale => :hu).split(','))[1], ((I18n.t 'labresult_header_values', :locale => :hu).split(','))[2]]
      elsif lang == "en"
        csv << [((I18n.t 'labresult_header_values', :locale => :en).split(','))[0], ((I18n.t 'labresult_header_values', :locale => :en).split(','))[1], ((I18n.t 'labresult_header_values', :locale => :en).split(','))[2]]
      end
      data.each do |item|
        csv << [item['date'].strftime("%Y-%m-%d %H:%M"),item['category'],item['value']]
      end
    end
  end

  def set_var
    @ketoneHash = {
        "Negative"=> "Negative",
        "1"=> "+",
        "2"=> "++",
        "3"=> "+++",
        "4"=> "++++",
        "5"=> "+++++"
    }
  end
end

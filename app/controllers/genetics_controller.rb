class GeneticsController < ApplicationController

  # GET /users/:id/genetics
  # GET /users/:id/genetics
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

    lang = params[:lang]
    table = params[:table]

    @personal_records = PersonalRecord.where("user_id = #{user_id}")
    if source
      @personal_records = @personal_records.where("source = '#{source}'")
    end
    if order and order=="desc"
      @personal_records = @personal_records.order(created_at: :desc)
    else
      @personal_records = @personal_records.order(created_at: :asc)
    end
    if limit and limit.to_i>0
      @personal_records = @personal_records.limit(limit)
    end

    @family_records = FamilyRecord.where("user_id = #{user_id}")
    if source
      @family_records = @family_records.where("source = '#{source}'")
    end
    if order and order=="desc"
      @family_records = @family_records.order(created_at: :desc)
    else
      @family_records = @family_records.order(created_at: :asc)
    end
    if limit and limit.to_i>0
      @family_records = @family_records.limit(limit)
    end
    @genetics_records = @personal_records + @family_records

    if table
      @genetics_records = get_table_data(@personal_records, @family_records, lang)
    end

    respond_to do |format|
      format.html
      format.json {render json: @genetics_records }
      format.csv { send_data to_csv(@personal_records,@family_records,{}, lang).encode("iso-8859-2"), :type => 'text/csv; charset=iso-8859-2; header=present' }
      format.js
    end
  end

  private

  def get_table_data(prec, frec, lang)
    tableData = []
    tableData2 = []
    if lang=='en'
      personal_record_type=(I18n.t 'personal_history', :locale => :en)
      family_record_type=(I18n.t 'family_history', :locale => :en)
    else
      personal_record_type=(I18n.t 'personal_history', :locale => :hu)
      family_record_type=(I18n.t 'family_history', :locale => :hu)
    end
    for item in prec
      if lang=='en'
        diab_key = DB_EN_CONFIG['genetics']['diabetes'][item.diabetes_key]
        anti_key = DB_EN_CONFIG['genetics']['autoantibody'][item.antibody_key]
        if item.antibody_kind
          kind = (I18n.t 'positive', :locale => :en)
        else
          kind = (I18n.t 'negative', :locale => :en)
        end
      else
        diab_key = DB_HU_CONFIG['genetics']['diabetes'][item.diabetes_key]
        anti_key = DB_HU_CONFIG['genetics']['autoantibody'][item.antibody_key]
        if item.antibody_kind
          kind = (I18n.t 'positive', :locale => :hu)
        else
          kind = (I18n.t 'negative', :locale => :hu)
        end
      end
      row = {"type"=>personal_record_type, "diabetes_key"=>diab_key, "property1" => anti_key , "property2"=>kind, "property3"=>item.antibody_value, "property4"=>item.note}
      tableData.push(row)
    end
    prec = tableData
    for item in frec
      if lang=='en'
        diab_key = DB_EN_CONFIG['genetics']['diabetes'][item.diabetes_key]
        rel_key = DB_EN_CONFIG['genetics']['relatives'][item.relative_key]
      else
        diab_key = DB_HU_CONFIG['genetics']['diabetes'][item.diabetes_key]
        rel_key = DB_HU_CONFIG['genetics']['relatives'][item.relative_key]
      end
      row = {"type"=>family_record_type, "diabetes_key"=>diab_key, "property1" => rel_key , "property2"=>item.note, "property3"=>"", "property4"=>""}
      tableData2.push(row)
    end
    frec = tableData2
    return prec + frec
  end

  def to_csv(prec,frec, options={}, lang = '')
    grec=get_table_data(prec,frec,lang)
    CSV.generate(options) do |csv|
      if lang == "hu"
        csv << [((I18n.t 'genetics_header_values', :locale => :hu).split(','))[0], ((I18n.t 'genetics_header_values', :locale => :hu).split(','))[1], ((I18n.t 'genetics_header_values', :locale => :hu).split(','))[2], ((I18n.t 'genetics_header_values', :locale => :hu).split(','))[3], ((I18n.t 'genetics_header_values', :locale => :hu).split(','))[4],((I18n.t 'genetics_header_values', :locale => :hu).split(','))[5]]
      elsif lang == "en"
        csv << [((I18n.t 'genetics_header_values', :locale => :en).split(','))[0], ((I18n.t 'genetics_header_values', :locale => :en).split(','))[1], ((I18n.t 'genetics_header_values', :locale => :en).split(','))[2], ((I18n.t 'genetics_header_values', :locale => :en).split(','))[3], ((I18n.t 'genetics_header_values', :locale => :en).split(','))[4], ((I18n.t 'genetics_header_values', :locale => :en).split(','))[5]]
      end
      grec.each do |item|
        csv << [item['type'],item['diabetes_key'],item['property1'],item['property2'],item['property3'], item['property4']]
      end
    end
  end

end

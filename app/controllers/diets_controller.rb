class DietsController < ApplicationController
  before_action :set_diet, only: [:edit, :update, :destroy]
  before_action :check_owner_or_doctor

  include DietsCommon

  # GET /diets
  # GET /diets.json
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

    favourites = params[:favourites]
    lang = params[:lang]
    table = params[:table]

    @diets = Diet.where("user_id = #{user_id}")
    if source
      @diets = @diets.where("source = '#{source}'")
    end
    if order and order=="desc"
      @diets = @diets.order(date: :desc)
    else
      @diets = @diets.order(date: :asc)
    end
    if limit and limit.to_i>0
      @diets = @diets.limit(limit)
    end

    if params[:year] and params[:month]
      year = params[:year].to_i
      month = params[:month].to_i
      numdays = Time.days_in_month(month, year)
      from = "#{year}-#{month}-01 00:00:00"
      to = "#{year}-#{month}-#{numdays} 23:59:59"
      @diets = @diets.where("date between '#{from}' and '#{to}'")
    end

    if favourites and favourites == "true"
      @diets = @diets.where(favourite: true)
    end

    if table
      @diets = get_table_data(@diets, lang)
    end

    respond_to do |format|
      format.html
      format.json {render json: @diets}
      format.csv { send_data to_csv(@diets, {}, lang).encode("iso-8859-2"), :type => 'text/csv; charset=iso-8859-2; header=present'}
      format.js
    end
  end

  def show
    set_diet
  end

  private

  def get_table_data(data, lang)
    tableData = []
    dietTypeList = FoodType.all

    for item in data
      amount1="-"
      amount2="-"
      category = dietTypeList.where(id: item.food_type_id).try(:first).try(:category)
      if category == 'Calory'
        if item.calories
          amount1 = item.calories.to_s+' kcal '+(I18n.t 'calories', :locale => lang)
        end
        if item.carbs
          amount2 = item.carbs.to_s+' g '+(I18n.t 'carbs', :locale => lang)
        end
      elsif category == "Drink"
        amount1= (0.25 + (0.25*item.amount)).to_s + ' dl'
      elsif category == "Smoke"
        amount1 = 1
      end
      if lang=='en'
        if category == "Food"
          amount1= ((I18n.t 'diet_food_amounts', :locale => :en).split(','))[item.amount]
        end
        cat = DB_EN_CONFIG['categories'][category]
        nk = dietTypeList.where(id: item.food_type_id).first.try(:name)
        name = ""
        unless nk.nil?
          name = DB_EN_CONFIG['diets'][category][nk]
        end
      else
        if category == "Food"
          amount1= ((I18n.t 'diet_food_amounts', :locale => :hu).split(','))[item.amount]
        end
        cat = DB_HU_CONFIG['categories'][category]
        nk = dietTypeList.where(id: item.food_type_id).first.try(:name)
        name = ""
        unless nk.nil?
          name = DB_HU_CONFIG['diets'][category][nk]
        end
      end
      row = {"date"=>item.date, "category"=>cat, "name"=>name ,"amount1"=>amount1 ,"amount2"=>amount2}
      tableData.push(row)
    end
    return tableData
  end

  def to_csv(data, options={}, lang = '')
    data=get_table_data(data,lang)
    CSV.generate(options) do |csv|
      if lang == "hu"
        csv << [((I18n.t 'diet_header_values', :locale => :hu).split(','))[0], ((I18n.t 'diet_header_values', :locale => :hu).split(','))[1], ((I18n.t 'diet_header_values', :locale => :hu).split(','))[2], ((I18n.t 'diet_header_values', :locale => :hu).split(','))[3], ((I18n.t 'diet_header_values', :locale => :hu).split(','))[4]]
      elsif lang == "en"
        csv << [((I18n.t 'diet_header_values', :locale => :en).split(','))[0], ((I18n.t 'diet_header_values', :locale => :en).split(','))[1], ((I18n.t 'diet_header_values', :locale => :en).split(','))[2], ((I18n.t 'diet_header_values', :locale => :en).split(','))[3], ((I18n.t 'diet_header_values', :locale => :en).split(','))[4]]
      end
      data.each do |item|
        csv << [item['date'].strftime("%Y-%m-%d %H:%M"),item['category'],item['name'],item['amount1'],item['amount2']]
      end
    end
  end
end

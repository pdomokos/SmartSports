class DietsController < ApplicationController
  include DietsCommon

  # GET /diets
  # GET /diets.json
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

    @is_mobile = false
    mobile = params[:mobile]
    if mobile and mobile=="true"
      @is_mobile = true
    end

    favourites = params[:favourites]

    @diets = Diet.where("user_id = #{user_id}")
    if source
      @diets = @diets.where("source = '#{source}'")
    end
    if order and order=="desc"
      @diets = @diets.order(created_at: :desc)
    else
      @diets = @diets.order(created_at: :asc)
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

    @diets = @diets.order(:date)

    if favourites and favourites == "true"
      @diets = @diets.where(favourite: true)
    end

    respond_to do |format|
      format.html
      format.json  { render :json => {:diets => @diets}}
      format.js
    end
  end

  def show
    set_diet
  end

  # POST /diets
  # POST /diets.json
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    puts diet_params
    @diet = user.diets.build(diet_params)
    if not @diet.date
      @diet.date = DateTime.now
    end

    if (@diet.type=='Food' || @diet.type=='Drink' ) && @diet.food_type
      ft = @diet.food_type
      @diet.calories = @diet.amount*ft.kcal
      @diet.carbs = @diet.amount*ft.carb
      @diet.fat = @diet.amount*ft.fat
      @diet.prot = @diet.amount*ft.prot
    end

    if @diet.save
      send_success_json(@diet.id, { diet_name: @diet.diet_name})
    else
      send_error_json(nil,  @diet.errors.full_messages.to_sentence, 400)
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_diet
    @diet = Diet.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def diet_params
    params.require(:diet).permit(:source, :name, :date, :calories, :carbs, :amount, :category, :type, :fat, :prot, :food_type_id)
  end
  def diet_update_params
    params.require(:diet).permit(:favourite, :amount, :date)
  end
end

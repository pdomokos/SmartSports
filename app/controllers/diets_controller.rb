class DietsController < ApplicationController

  # GET /diets
  # GET /diets.json
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

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

    respond_to do |format|
      format.html
      format.json {render json: @diets }
      format.js
    end
  end

  # POST /diets
  # POST /diets.json
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    @diet = user.diets.build(diet_params)
    if not @diet.date
      @diet.date = DateTime.now
    end
    respond_to do |format|
      if @diet.save
        format.json { render json: {:status => "OK", :result => @diet} }
      else
        logger.error @diet.errors.full_messages.to_sentence
        format.json { render json: { :msg =>  @diet.errors.full_messages.to_sentence }, :status => 400 }
      end
    end
  end

  # DELETE /diets/1
  # DELETE /diets/1.json
  def destroy
    set_diet
    respond_to do |format|
      if @diet.destroy
        format.json { render json: { :status => "OK", :msg => "Deleted successfully" } }
      else
        format.json { render json: { :status => "NOK", :msg => "Delete errror" }, :status => 400 }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_diet
    @diet = Diet.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def diet_params
    params.require(:diet).permit(:source, :name, :date, :calories, :carbs, :amount, :type)
  end
end

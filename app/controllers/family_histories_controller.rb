class FamilyHistoriesController < ApplicationController

  # GET /users/:id/family_histories
  # GET /users/:id/family_histories.json
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

    @family_histories = FamilyHistory.where("user_id = #{user_id}")
    if source
      @family_histories = @family_histories.where("source = '#{source}'")
    end
    if order and order=="desc"
      @family_histories = @family_histories.order(created_at: :desc)
    else
      @family_histories = @family_histories.order(created_at: :asc)
    end
    if limit and limit.to_i>0
      @family_histories = @family_histories.limit(limit)
    end

    respond_to do |format|
      format.html
      format.json {render json: @family_histories }
      format.js
    end
  end

  # POST /users/:id/family_histories
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    @family_history = user.family_histories.build(family_history_params)

    respond_to do |format|
      if @family_history.save
        format.json { render json: {:status => "OK", :result => @family_history} }
      else
        logger.error @family_history.errors.full_messages.to_sentence
        format.json { render json: { :msg =>  @family_history.errors.full_messages.to_sentence }, :status => 400 }
      end
    end
  end

  # DELETE /users/:user_id/family_histories/:id
  def destroy
    set_family_history
    respond_to do |format|
      if @family_history.destroy
        format.json { render json: { :status => "OK", :msg => "Deleted successfully" } }
      else
        format.json { render json: { :status => "NOK", :msg => "Delete errror" }, :status => 400 }
      end
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_family_history
    @family_history = FamilyHistory.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def family_history_params
    params.require(:family_history).permit(:source, :relative, :disease, :note)
  end
end

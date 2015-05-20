class LabResultsController < ApplicationController
  include LabResultsCommon
  include SaveClickRecord

  def index
    user_id = params[:user_id]

    order = params[:order]
    limit = params[:limit]

    @labresults = LabResult.where("user_id = #{user_id}")

    if order and order=="desc"
      @labresults = @labresults.order(created_at: :desc)
    else
      @labresults = @labresults.order(created_at: :asc)
    end
    if limit and limit.to_i>0
      @labresults = @labresults.limit(limit)
    end

    respond_to do |format|
      format.json {render json: @labresults}
      format.js
    end
  end

  # POST /users/[user_id]/lab_results
  # POST /users/[user_id]/lab_results.json
  def create
    user_id = params[:user_id]
    par = labresult_params
    par.merge!(:user_id => user_id)
    print par
    labresult = LabResult.new(par)

    respond_to do |format|
      if labresult.save
        save_click_record(current_user.id, true, nil)
        format.json { render  json: {:status =>"OK", :result => labresult} }
      else
        print labresult.errors.full_messages.to_sentence+"\n"
        save_click_record(current_user.id, false, labresult.errors.full_messages.to_sentence)
        format.json { render json: labresult.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def labresult_params
    params.require(:labresult).permit(:user_id, :source, :category, :hba1c, :ldl_chol, :egfr_epi, :ketone, :date)
  end

end

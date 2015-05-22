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

  # send_success_json(medication.id, {medication_name: medication.medication_type.name})
  # send_error_json(medication.id, medication.errors.full_messages.to_sentence, 401)

  # POST /users/[user_id]/lab_results
  # POST /users/[user_id]/lab_results.json
  def create
    user_id = params[:user_id]
    par = labresult_params
    par.merge!(:user_id => user_id)
    print par
    labresult = LabResult.new(par)

    if labresult.save
      send_success_json(labresult.id, {category: labresult.category})
    else
      send_error_json(nil, labresult.errors.full_messages.to_sentence, 401)
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def labresult_params
    params.require(:labresult).permit(:user_id, :source, :category, :hba1c, :ldl_chol, :egfr_epi, :ketone, :date)
  end

end

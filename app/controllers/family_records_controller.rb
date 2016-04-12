class FamilyRecordsController < ApplicationController

  include FamilyRecordsCommon

  # GET /users/:id/family_records
  # GET /users/:id/family_records
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

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

    respond_to do |format|
      format.html
      format.json {render json: @family_records }
      format.js
    end
  end

end

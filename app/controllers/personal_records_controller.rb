class PersonalRecordsController < ApplicationController

  include PersonalRecordsCommon

  # GET /users/:id/personal_records
  # GET /users/:id/personal_records
  def index
    user_id = params[:user_id]
    source = params[:source]

    order = params[:order]
    limit = params[:limit]

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

    respond_to do |format|
      format.html
      format.json {render json: @personal_records }
      format.js
    end
  end

end

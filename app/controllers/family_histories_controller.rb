class FamilyHistoriesController < ApplicationController

  include FamilyHistoriesCommon

  # GET /users/:id/family_histories
  # GET /users/:id/family_histories.json
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

end

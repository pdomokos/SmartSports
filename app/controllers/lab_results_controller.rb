class LabResultsController < ApplicationController
  include LabResultsCommon
  include SaveClickRecord

  def index
    user_id = params[:user_id]

    order = params[:order]
    limit = params[:limit]

    lang = params[:lang]
    if lang
      I18n.locale=lang
    end

    @is_mobile = false
    mobile = params[:mobile]
    if mobile and mobile=="true"
      @is_mobile = true
    end

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

end

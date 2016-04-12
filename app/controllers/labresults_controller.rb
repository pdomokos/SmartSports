class LabresultsController < ApplicationController
  include LabresultsCommon
  include SaveClickRecord
  before_action :set_var
  def index
    user_id = params[:user_id]

    order = params[:order]
    limit = params[:limit]

    @labresults = Labresult.where("user_id = #{user_id}")

    if order and order=="desc"
      @labresults = @labresults.order(date: :desc)
    else
      @labresults = @labresults.order(date: :asc)
    end
    if limit and limit.to_i>0
      @labresults = @labresults.limit(limit)
    end

    respond_to do |format|
      format.json {render json: @labresults}
      format.js
    end
  end

  private
  def set_var
    @ketoneHash = {
        "Negative"=> "Negative",
        "1"=> "+",
        "2"=> "++",
        "3"=> "+++",
        "4"=> "++++",
        "5"=> "+++++"
    }
  end
end

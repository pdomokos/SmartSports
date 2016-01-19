class MedicationsController < ApplicationController
  include MedicationsCommon

  def show
    user = User.find(params[:user_id])
    @medication = user.medications.where(id: params[:id]).first
  end

  def index
    user_id = params[:user_id]

    source = params[:source]
    order = params[:order]
    limit = params[:limit]
    favourites = params[:favourites]

    u = User.find(user_id)
    @medications = u.medications

    if source and source !=""
      @medications = @medications.where(source: source)
    end
    if order and order=="desc"
      @medications = @medications.order(date: :desc)
    else
      @medications = @medications.order(date: :asc)
    end
    if limit and limit.to_i>0
      @medications = @medications.limit(limit)
    end
    @user = u

    if favourites and favourites == "true"
      @medications = @medications.where(favourite: true)
    end

    respond_to do |format|
      format.json {render json: @medications}
      format.js
    end
  end

end

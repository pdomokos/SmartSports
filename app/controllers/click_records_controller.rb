class ClickRecordsController < ApplicationController
  respond_to :json

  def index
    if !current_user.admin
      render json: { :status => 'NOK', :msg => 'error_unauthorized' }, status: 403
      return
    end

    rec = ClickRecord.all
    if params[:limit]
      rec = rec.limit(params[:limit].to_i)
    end
    if params[:user_id]
      rec = rec.where(user_id: params[:user_id].to_i)
    end
    rec = rec.order(created_at: :desc)
    render json: rec
  end

  private

end

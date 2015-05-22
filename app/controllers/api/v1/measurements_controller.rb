module Api::V1
  class MeasurementsController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!
    before_action :set_measurement, only: [ :update, :destroy]
    respond_to :json

    include MeasurementsCommon

    def index
      lim = 10
      if params[:limit]
        lim = params[:limit].to_i
      end
      user_id = params[:user_id]

      if current_resource_owner.id != user_id.to_i
        render json: nil, status: 403
        return
      end

      user = User.find(user_id)
      measurements = user.measurements.where(source: @default_source).order(created_at: :desc).limit(lim)
      render json: measurements
    end
  end
end

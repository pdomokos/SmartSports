module Api::V1
  class MeasurementsController < ApiController
    before_action :set_measurement, only: [ :update, :destroy]

    include MeasurementsCommon

    def index
      lim = 10
      days = 50
      if params[:limit]
        lim = params[:limit].to_i
      end
      if params[:days]
        days = params[:days].to_i
      end
      user_id = params[:user_id]

      if current_resource_owner.id != user_id.to_i
        render json: nil, status: 403
        return
      end

      user = User.find(user_id)
      from_date=Date.current-days.days
      # src = @default_source
      src = 'demo'
      measurements = user.measurements.where("source = :src AND date >= :from_date",{src: src, from_date: from_date}).order(created_at: :desc).limit(lim)
      #measurements = user.measurements.where(source: @default_source).order(created_at: :desc).limit(lim)
      render json: measurements
    end
  end
end

module Api::V1
  class MeasurementsController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!
    respond_to :json

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
      measurements = user.measurements.where(source: @default_source).order(date: :desc).limit(lim)
      render json: measurements
    end

    def create
      user_id = params[:user_id]
      user = User.find(user_id)

      if current_resource_owner.id != user_id.to_i
        render json: { :ok => false}, status: 403
        return
      end

      measurement = user.measurements.new(measurement_params)
      if not measurement.date
        measurement.date = DateTime.now
      end
      if measurement.save
        render json: { :ok => true, :id => measurement.id }
      else
        render json: { :ok => false, :message =>  measurement.errors.full_messages.to_sentence}, status: 400
      end
    end

    def update
      measurement = Measurement.find_by_id(params[:id])
      if measurement.nil?
        render json: { :ok => false }, status: 400
        return
      end
      if measurement.user_id != current_resource_owner.id
        render json: { :ok => false }, status: 403
        return
      end
      if measurement.update(measurement_params)
        render json: { :ok => true }
      else
        render json: {:ok => false, :msg => "Update failed" }, status: 400
      end
    end

    # DELETE /measurements/1
    # DELETE /measurements/1.json
    def destroy
      measurement = Measurement.find_by_id(params[:id])
      if measurement.nil?
        render json: { :ok => false }, status: 400
        return
      end
      if measurement.user_id != current_resource_owner.id
        render json: { :ok => false }, status: 403
        return
      end
      if measurement.destroy
        render json: { :status => "OK", :msg => "Deleted successfully" }
      else
        render json: { :status => "NOK", :msg => "Delete errror" }, :status => 400
      end
    end

    private
    def measurement_params
      params.require(:measurement).permit(:source, :systolicbp, :diastolicbp, :pulse, :blood_sugar, :weight, :waist, :date, :meas_type, :favourite)
    end

  end

end

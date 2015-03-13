module Api::V1
  class MeasurementsController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!, only: [:index, :create]
    respond_to :json

    def index
      lim = 10
      if params[:limit]
        lim = params[:limit].to_i
      end
      user_id = params[:user_id]

      if current_resource_owner.id != user_id.to_i
        self.response.status = 403
      end

      user = User.find(user_id)
      respond_with @measurements = user.measurements.where(source: 'smartsport').order(date: :desc).limit(lim)
    end

    def create
      user_id = params[:user_id]
      user = User.find(user_id)

      puts "RESOWN=#{current_resource_owner.id}"
      if current_resource_owner.id != user_id.to_i
        self.response.status = 403
      end

      measurement = user.measurements.new(measurement_params)
      if not measurement.date
        measurement.date = DateTime.now
      end
      if measurement.save
        self.response_body = { :ok => true, :id => measurement.id }.to_json
      else
        self.response_body = { :ok => false, :message =>  measurement.errors.full_messages.to_sentence}.to_json
        self.response.status = 400
      end
    end

    private
    def measurement_params
      params.require(:measurement).permit(:source, :systolicbp, :diastolicbp, :pulse, :blood_sugar, :weight, :waist, :date)
    end

    def general_error_handler(ex)
      logger.error ex.message
      logger.error ex.backtrace.join("\n")
      self.response.status = 400
    end
  end

end

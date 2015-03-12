module Api::V1
  class MeasurementsController < ApiController
    before_action :doorkeeper_authorize!, only: [:index, :create]
    respond_to :json

    def index
      lim = 10
      if params[:limit]
        lim = params[:limit].to_i
      end
      user_id = params[:user_id]
      user = User.find(user_id)
      respond_with @measurements = user.measurements.where(source: 'smartsport').order(date: :desc).limit(lim)
    end

    def create
    #   user_id = params[:user_id]
    #   # par = measurement_params
    #   # par.merge!(:user_id => user_id)
    #   # print par
    #   @measurement = Measurement.new(params)
    #   @measurement.date = DateTime.now
    #   if @measurement.save(par)
    #     self.response_body = { :ok => true }.to_json
    #   else
    #     self.response_body = { :ok => false }.to_json
    #   end
    end
  end

end

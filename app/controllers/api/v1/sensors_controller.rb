require 'base64'
require 'date'

module Api::V1
  class SensorsController < ApiController
    rescue_from Exception, :with => :general_error_handler

    respond_to :json

    def create
      puts params

      #rr1 = "zAO7A80D2gO4A80DwAOTA2wDgAOVA5oDjAM="
      #Base64.decode64(rr1).bytes.each_slice(2).to_a.collect{|it| it[1]*256+it[0]}

      #hr1 = "KgM9AN4DPQDeAz0A/AM9AN4DPQDeAz0A/QM9AN0DPADeAzwA/AM8AN4DPADfAzwA/AM7AN4DPADdAzwA/AM7AN4DOwDeAzsA/AM7AA=="

      #DateTime.strptime("1318996912",'%s')

      render json: {:ok => "true"}
    end
  end
end


require 'base64'
require 'date'
require 'csv'

module Api::V1
  class SensorMeasurementsController < ApiController
    rescue_from Exception, :with => :general_error_handler

    respond_to :json

    def create
      user_id = params[:user_id]
      user = User.find(user_id)

      puts params

      #rr1 = "zAO7A80D2gO4A80DwAOTA2wDgAOVA5oDjAM="
      #Base64.decode64(rr1).bytes.each_slice(2).to_a.collect{|it| it[1]*256+it[0]}

      #hr1 = "KgM9AN4DPQDeAz0A/AM9AN4DPQDeAz0A/QM9AN0DPADeAzwA/AM8AN4DPADfAzwA/AM7AN4DPADdAzwA/AM7AN4DOwDeAzsA/AM7AA=="

      #DateTime.strptime("1318996912",'%s')

      sens = SensorMeasurement.new(sensor_measurement_params)
      sens.user_id = user.id
      if sens.save
        render json: {:ok => "true", :id => sens.id}
      else
        render json: {:ok => "false"}, :status => 400
      end

    end

    def proc
      s = nil
      rootdir = "/Users/bdomokos/Downloads/"
      File.open("#{rootdir}hrdata2.json", 'r') do |f|
        s = f.read()
      end
      hrdata = JSON.parse(s)
      rr = Base64.decode64(hrdata['rrData']).bytes.each_slice(2).to_a.collect{|it| it[1]*256+it[0]}
      hr = Base64.decode64(hrdata['hrData']).bytes.each_slice(2).to_a.collect{|it| it[1]*256+it[0]}

      CSV.open("#{rootdir}/rr.csv", 'w') do |csv|
        rr.each {|it| csv << [it]}
      end

      CSV.open("#{rootdir}/hr.csv", 'w') do |csv|
        hr.each_slice(2) {|a, b| csv << [a, b]}
      end
    end

    private
    def sensor_measurement_params
      params.require(:sensor_measurement).permit(:user_id, :hr_data, :rr_data, :start_time, :group)
    end

  end
end


require 'base64'
require 'date'
require 'csv'

module Api::V1
  class SensorMeasurementsController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!, only: [:index, :create]

    respond_to :json

    def create
      user_id = params[:user_id]
      user = User.find(user_id)

      if current_resource_owner.id != user.id
        render json: { :ok => false}, status: 403
        return
      end

      toDump = params.clone
      toDump.delete('sensor_measurement')
      fname = File.join(DATA_DIR, "sensor_uid_#{user_id}_#{Time.zone.strptime(params[:sensor_measurement][:start_time], "%Y-%m-%d %H:%M:%S %Z").strftime("%Y%m%d%H%M%S")}.json")
      File.open(fname, 'w') do |f|
        JSON.dump(toDump.as_json, f)
      end


      #rr1 = "zAO7A80D2gO4A80DwAOTA2wDgAOVA5oDjAM="
      #Base64.decode64(rr1).bytes.each_slice(2).to_a.collect{|it| it[1]*256+it[0]}

      #hr1 = "KgM9AN4DPQDeAz0A/AM9AN4DPQDeAz0A/QM9AN0DPADeAzwA/AM8AN4DPADfAzwA/AM7AN4DPADdAzwA/AM7AN4DOwDeAzsA/AM7AA=="

      #DateTime.strptime("1318996912",'%s')

      sens = SensorMeasurement.new(sensor_measurement_params)
      sens.user_id = user.id
      if params[:duration] && params[:duration].to_i > 0
        sens.end_time = sens.start_time + params[:duration].to_i
      end
      if params[:version]
        sens.version = params[:version]
      end

      if !sens.save
        render json: {:ok => "false", :msg => sens.errors.full_messages.to_sentence}, :status => 400
        return
      end

      if sens.version == '2.0' && params['data']
        data = params['data']
        data.keys.sort.each do |sid|
          stype = data[sid]['sensor_type']
          sd = sens.sensor_data.create({sensor_id: sid, sensor_type: stype})
          segments = data[sid]['segments']
          segments.each do |seg|
            if stype=='HEART'
              sensor_segment = sd.sensor_segments.create({start_time: seg['start_time'],
                                                         data_a: seg['hr_data'],
                                                         data_b: seg['rr_data']})
            elsif stype=='HEART'
              sensor_segment = sd.sensor_segments.create({start_time: seg['start_time'],
                                                          data_a: seg['cr_data']})
            end
          end
        end
      end

      # sens.start_time = Time.zone.strptime(sens.start_time, "%Y-%m-%d %H:%M:%S %Z")

      render json: {:ok => "true", :id => sens.id}

    end

    private
    def sensor_measurement_params
      params.require(:sensor_measurement).permit(:user_id, :hr_data, :rr_data, :cr_data, :start_time, :group, :duration, :sensors)
    end

    def decodeit(d)
      Base64.decode64(d).bytes.each_slice(2).to_a.collect{|it| it[1]*256+it[0]}
    end

  end
end


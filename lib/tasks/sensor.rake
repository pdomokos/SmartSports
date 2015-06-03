require 'sensor_helper'

namespace :sensor do
  "Load sensor json"
  task :load_sensor_json, [:fname, :user_id] => :environment do |t, args|
    if args[:fname].nil?
      puts "Usage: rake sensor:load_sensor_json 'json_file_path' [<userid>]"
    elsif not File.exists?(args[:fname])
      puts "File missing: #{args[:fname]}"
    else
      fname = args[:fname]
      File.open(fname, 'r') do |f|
        par = JSON.load(f)

        sens = nil
        if par.has_key?('sensor_measurement')
          sens = SensorMeasurement.create(par['sensor_measurement'])
        else
          sens = SensorMeasurement.create(par)
        end

        if not args[:user_id].nil?
          sens.user_id = args[:user_id].to_i
        else
          sens.user_id = par['user_id']
        end

        sens.save!
        puts  "Loaded: #{fname}, id: #{sens.id}"
      end
    end
  end

  task :export_sensor_json, [:sens_id, :fdir] => :environment do |t, args|
    if args[:fdir].nil?
      puts "Usage: rake sensor:export_sensor_json 'json_dir' <sensor_data_id>"
    elsif not File.exist?(args[:fdir]) or not  File.directory?(args[:fdir])
      puts "json_dir must be an existing directory"
    else
      sens = SensorMeasurement.find_by_id(args[:sens_id].to_i)
      if sens.nil?
        puts "Sensor data with id #{args[:sens_id]} doesn't exist"
      else
        fname = File.join(args[:fdir], "sensor_uid_#{sens.user_id}_#{sens.start_time.to_i}.json")
        if File.exists?(fname)
          puts "File '#{fname}' exists, not overwriting"
        else
          File.open(fname, 'w') do |f|
            JSON.dump(sens.as_json, f)
          end
          puts "#{fname} saved"
        end
      end
    end
  end

end

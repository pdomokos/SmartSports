require 'sensor_helper'

namespace :sensor do
  "Load sensor json"
  task :load_sensor_json, [:fname] do |t, args|
    if args[:fname].nil?
      puts "Usage: rake sensor:load_sensor_json['json_file_path']"
    elsif not File.exists?(File.path(args[:fname]))
      puts "File missing: #{args[:fname]}"
    else
      puts  "Loading: #{args[:fname]}"
    end

  end
end

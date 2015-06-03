module SensorHelper
  
  def proc_export_json
    rootdir = "/home/pdomokos/Downloads/"
    u = User.find(1)
    lst = u.sensor_measurements.all

    File.open("#{rootdir}sensordata_20150507.json", 'w') do |f|
      JSON.dump(lst.as_json, f)
    end
  end
  def proc_import_json
    arr = nil
    rootdir = "/Users/bdomokos/Downloads/"
    File.open("#{rootdir}sensordata_20150507.json", 'r') do |f|
      arr = JSON.parse(f.read())
    end
    for data in arr do
      sensorData = SensorMeasurement.new(data)
      sensorData.save!
    end
  end

  def proc_to_csv
    s = nil
    rootdir = "/Users/bdomokos/Downloads/"
    File.open("#{rootdir}hr_cycling_0501.json", 'r') do |f|
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

end
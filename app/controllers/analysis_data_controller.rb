class AnalysisDataController < ApplicationController
  respond_to :json

  def index
    user_id = params[:user_id]

    result = []
    user = User.find(user_id)
    activities = user.activities

    f=nil
    t=nil
    if params[:date]
      date = params[:date]
      activities = activities.where("start_time between '#{date} 00:00:00' and '#{date} 23:59:59'")
      f = Time.zone.parse(date+' 00:00:00')
      t = Time.zone.parse(date+' 23:59:59')
    end

    result.concat(activities.collect{|act| {
                      id: act.id,
                      title: act.try(:activity_type).try(:name),
                      depth: 0,
                      dates: [act.start_time, act.end_time],
                      evt_type: 'exercise'
                  }})

    diets = user.diets
    if f
      diets = diets.where("date between ? and ?", f, t)
    end
    result.concat(diets.collect{|diet| {
                      id: diet.id,
                      title: diet.try(:food_type).try(:name),
                      depth: 0,
                      dates: [diet.date],
                      evt_type: 'diet'
                  }})

    measurements = user.measurements
    if f
      measurements = measurements.where("date between ? and ?", f, t)
    end
    meas_arr = []
    meas_arr.concat(measurements.collect{|measurement| {
                      id: measurement.id,
                      title: measurement.get_title,
                      depth: 0,
                      dates: [measurement.date],
                      evt_type: 'measurement',
                      meas_type: measurement.meas_type,
                      values: [measurement.systolicbp, measurement.diastolicbp, measurement.pulse]
                  }})
    result.concat(meas_arr)

    lifestyles = user.lifestyles.where(group: 'sleep')
    if f
      lifestyles = lifestyles.where("(start_time between ? and ?) OR (end_time between ? and ?)", f, t, f, t )
    end
    result.concat(lifestyles.collect{|lifestyle| {
                      id: lifestyle.id,
                      title: lifestyle.tooltip,
                      depth: 0,
                      dates: [lifestyle.start_time, lifestyle.end_time],
                      evt_type: 'lifestyle'
                  }})


    medications = user.medications.where("date between ? and ?", f, t)
    result.concat(medications.collect{|med| {
                      id: med.id,
                      title: med.try(:medication_type).try(:name)+" : #{med.amount}",
                      depth: 0,
                      dates: [med.date],
                      evt_type: 'medication',
                      group: med.try(:medication_type).try(:group),
                  }})
    
    sensors = user.sensor_measurements.where("start_time between ? and ?", f, t)
    for sens in sensors do
      if sens.hr_data
        raw = Base64.decode64(sens.hr_data).bytes.each_slice(2).to_a.collect{|it| it[1]*256+it[0]}
        curr_time = sens.start_time.to_f
        last_time = curr_time
        val = []
        raw.in_groups_of(2) do |delta, hr|
          curr_time += delta/1000.0
          if curr_time-last_time > 60.0
            val.append({time: curr_time.to_i, data:hr})
            last_time = curr_time
          end
        end
        result.concat([{
                          id: sens.id,
                          title: sens.group,
                          start_time: sens.start_time,
                          values: val,
                          evt_type: 'sensor'
                      }])
      end
    end
    render json: result
  end
end

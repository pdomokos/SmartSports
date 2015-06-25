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
      f = Time.zone.parse(date+' 00:00:00')
      t = Time.zone.parse(date+' 23:59:59')
      activities = activities.where("start_time between ? and ?", f, t)
    end

    result.concat(activities.collect{|act| {
                      id: act.id,
                      tooltip: act.try(:activity_type).try(:name),
                      title: 'Exercise',
                      depth: 0,
                      dates: [act.start_time, act.end_time],
                      evt_type: 'exercise',
                      source: 'SmartDiab'
                  }})

    diets = user.diets
    if f
      diets = diets.where("date between ? and ?", f, t)
    end
    result.concat(diets.collect{|diet| {
                      id: diet.id,
                      tooltip: diet.try(:food_type).try(:name),
                      title: 'Diet',
                      depth: 0,
                      dates: [diet.date],
                      evt_type: 'diet',
                      source: 'SmartDiab'
                  }})

    measurements = user.measurements
    if f
      measurements = measurements.where("date between ? and ?", f, t)
    end
    meas_arr = []
    meas_arr.concat(measurements.collect do |measurement|
                      ret = {
                        id: measurement.id,
                        tooltip: measurement.get_title,
                        title: 'Health',
                        depth: 0,
                        dates: [measurement.date],
                        evt_type: 'measurement',
                        meas_type: measurement.meas_type,
                        source: 'SmartDiab'
                      }

                      if measurement.meas_type=='blood_pressure'
                        ret['values']= [measurement.systolicbp, measurement.diastolicbp, measurement.pulse]
                      elsif measurement.meas_type=='blood_sugar'
                        ret['values'] = [measurement.blood_sugar]
                      end

                      ret
                      end
                    )
    result.concat(meas_arr)

    lifestyles = user.lifestyles.where(group: 'sleep')
    if f
      lifestyles = lifestyles.where("(start_time between ? and ?) OR (end_time between ? and ?)", f, t, f, t )
    end
    result.concat(lifestyles.collect{|lifestyle| {
                      id: lifestyle.id,
                      tooltip: lifestyle.tooltip,
                      title: 'Lifestyle',
                      depth: 0,
                      dates: [lifestyle.start_time, lifestyle.end_time],
                      evt_type: 'lifestyle',
                      source: 'SmartDiab'
                  }})


    medications = user.medications.where("date between ? and ?", f, t)
    result.concat(medications.collect{|med| {
                      id: med.id,
                      tooltip: med.try(:medication_type).try(:name)+" : #{med.amount}",
                      title: 'Medication',
                      depth: 0,
                      dates: [med.date],
                      evt_type: 'medication',
                      group: med.try(:medication_type).try(:group),
                      source: 'SmartDiab'
                  }})
    
    sensors = user.sensor_measurements.where("(start_time between ? and ?) OR (end_time between ? and ?)", f, t, f, t)
    for sens in sensors do
      if sens.hr_data
        raw = Base64.decode64(sens.hr_data).bytes.each_slice(2).to_a.collect{|it| it[1]*256+it[0]}
        curr_time = sens.start_time.to_f
        last_time = curr_time
        val = []
        tot = 0
        n = 0
        raw.in_groups_of(2) do |delta, hr|
          curr_time += delta/1000.0
          if curr_time-last_time > 60.0
            val.append({time: curr_time.to_i, data:tot/n})
            last_time = curr_time
          else
            tot += hr
            n += 1
          end
        end
        result.concat([{
                          id: sens.id,
                          tooltip: sens.group,
                          title: 'Sensor',
                          start_time: sens.start_time,
                          values: val,
                          evt_type: 'sensor',
                          source: 'SmartDiab'
                      }])
      end
    end

    # tracker data
    tracker_data = user.tracker_data.where("(start_time between ? and ?) OR (end_time between ? and ?)", f, t, f, t).where.not(group: 'transport')
    tracker_filtered = tracker_data.select{|d|
      d['activity']!='transport' && (d['activity']!='walking'||(d['end_time']-d['start_time']>240.0))
    }.collect {|d|
      title = 'Exercise'
      etype = 'exercise'
      if d.activity=='sleep'
        title = 'Well-being'
        etype = 'wellbeing'
      end
      {
          id: d.id,
          tooltip: d.activity.capitalize,
          title: title,
          source: d.source.capitalize,
          depth: 0,
          evt_type: etype,
          dates: [d.start_time, d.end_time]
        }
    }
    result.concat(tracker_filtered)

    render json: result
  end
end

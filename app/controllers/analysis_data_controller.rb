require 'csv'
class AnalysisDataController < ApplicationController
  respond_to :json

  def index
    user_id = params[:user_id]
    user = User.find(user_id)

    f=nil
    t=nil
    if params[:date]
      date = params[:date]
      if params[:weekly]
        f = Time.zone.parse(date).at_beginning_of_week
        t = Time.zone.parse(date).at_end_of_week
      else
        f = Time.zone.parse(date).at_beginning_of_day
        t = Time.zone.parse(date).at_end_of_day
        end
    end

    result = nil
    if params[:tabular]
      result = get_tabular_data(user, f, t)
    else
      result = get_timeline_data(user, f, t)
    end

    respond_to do |format|
      format.csv {
        d = result.collect do |it|
          if it.member?(:start) && it[:start]
            start = it[:start].strftime("%F %R")
          else
            start = nil
          end
          if it.member?(:end) && it[:end]
            e = it[:end].strftime("%F %R")
          else
            e = nil
          end
          [start, e, it[:evt_type], it[:group], it[:value1], it[:value2] ].to_csv(row_sep:nil)
        end.join("\n")
        send_data d
      }
      format.json { render json: result}
    end
  end

  def get_timeline_data(user, f, t)
    result = []

    activities = user.activities

    if f
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

    lifestyles = user.lifestyles
    if f
      lifestyles = lifestyles.where("(start_time between ? and ?) OR (end_time between ? and ?)", f, t, f, t )
    end
    lifes_arr = []
    lifes_arr.concat(lifestyles.collect do |lifestyle|
      ret = {
          id: lifestyle.id,
          tooltip: lifestyle.tooltip,
          title: 'Lifestyle',
          depth: 0,
          dates: [lifestyle.start_time, lifestyle.end_time],
          evt_type: 'lifestyle',
          amount: lifestyle.amount,
          source: 'SmartDiab'
      }
      if lifestyle.group=='stress'
        ret['lf_group']= [lifestyle.group, "Stress"]
      elsif lifestyle.group=='illness'
        ret['lf_group']= [lifestyle.group, IllnessType.find(lifestyle.illness_type_id).name]
      elsif lifestyle.group=='pain'
        ret['lf_group']= [lifestyle.group, lifestyle.pain_type_name+"(pain)"]
      end
      ret
    end
    )
    result.concat(lifes_arr)

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
      if sens.version && sens.version =='2.0'
        proc_20_sensor(sens, result)
      else
        proc_old_sensor(sens, result)
      end
    end

    # tracker data
    tracker_data = user.tracker_data.where("(start_time between ? and ?) OR (end_time between ? and ?)", f, t, f, t).where.not(group: 'transport')
    tracker_filtered = tracker_data.select{|d|
      !d.activity.nil? && d.activity!='transport' && (d.activity!='walking'||(d.end_time-d.start_time>240.0))
    }.collect {|d|
      title = 'Exercise'
      etype = 'exercise'
      if d.activity=='sleep'
        title = 'Well-being'
        etype = 'wellbeing'
      end
      {
          id: d.id,
          tooltip: d.activity.try(:capitalize),
          title: title,
          source: d.source.capitalize,
          depth: 0,
          evt_type: etype,
          dates: [d.start_time, d.end_time]
      }
    }
    result.concat(tracker_filtered)

    return result
  end

  def get_tabular_data(user, f, t)
    result = []

    activities = user.activities

    if f
      activities = activities.where("start_time between ? and ?", f, t)
    end

    result.concat(activities.collect{|act| {
                      start: act.start_time,
                      end: act.end_time,
                      evt_type: 'activity',
                      group: act.group=='sport'?'exercise':'regular',
                      value1: act.activity_type_id,
                      value2: nil
                  }})

    diets = user.diets
    if f
      diets = diets.where("date between ? and ?", f, t)
    end
    result.concat(diets.collect{|diet| {
                      start: diet.date,
                      end: nil,
                      evt_type: 'diet',
                      group: diet.diet_type.downcase,
                      value1: diet.calories,
                      value2: diet.carbs
                  }})

    measurements = user.measurements
    if f
      measurements = measurements.where("date between ? and ?", f, t)
    end
    meas_arr = []
    meas_arr.concat(measurements.collect do |measurement|
                      grp = measurement.meas_type
                      ret = []
                      if grp=='blood_pressure'
                        if measurement.systolicbp
                          item = {
                              start: measurement.date,
                              end: nil,
                              evt_type: 'measurement',
                              group: 'systolic',
                              value1: measurement.systolicbp,
                              value2: nil
                          }
                          ret.append(item)
                        end
                        if measurement.diastolicbp
                          item = {
                              start: measurement.date,
                              end: nil,
                              evt_type: 'measurement',
                              group: 'diastolic',
                              value1: measurement.diastolicbp,
                              value2: nil
                          }
                          ret.append(item)
                        end
                        if measurement.pulse
                          item = {
                              start: measurement.date,
                              end: nil,
                              evt_type: 'measurement',
                              group: 'pulse',
                              value1: measurement.pulse,
                              value2: nil
                          }
                          ret.append(item)
                        end
                      else
                        ret = {
                            start: measurement.date,
                            end: nil,
                            evt_type: 'measurement',
                            group: grp,
                            value1: nil,
                            value2: nil
                        }

                        if measurement.meas_type=='blood_sugar'
                          ret[:value1] = measurement.blood_sugar.try(:round, 2)
                        elsif measurement.meas_type=='weight'
                          ret[:value1] = measurement.weight
                        elsif measurement.meas_type=='waist'
                          ret[:value1] = measurement.waist
                        end

                      end

                      ret
                    end
    )
    result.concat(meas_arr.flatten)

    lifestyles = user.lifestyles
    if f
      lifestyles = lifestyles.where("(start_time between ? and ?) OR (end_time between ? and ?)", f, t, f, t )
    end
    lifes_arr = []
    lifes_arr.concat(lifestyles.collect do |lifestyle|
      ret = {
          start: lifestyle.start_time,
          evt_type: 'lifestyle',
          group: lifestyle.group,
          value1: lifestyle.amount
      }
      if lifestyle.group != 'stress'
        ret['end'] = lifestyle.end_time
      else
        ret['end'] = lifestyle.start_time+1.day
      end
      if lifestyle.group=='illness'
        ret['value2']= IllnessType.find(lifestyle.illness_type_id).name
      elsif lifestyle.group=='pain'
        ret['value2']= lifestyle.pain_type_name
      else
        ret['value2']= nil
      end
      ret
    end
    )
    result.concat(lifes_arr)

    return result
  end

  def proc_20_sensor(sens, result)
    sens.sensor_data.select{ |d| d.sensor_type=='HEART'}.each do |sd|
      sd.sensor_segments.each do |seg|
        result.concat(extract_hr_data(sens.id, sens.group, seg.data_a, seg.start_time))
      end
    end
  end
  def proc_old_sensor(sens, result)
    if sens.hr_data
      result.concat(extract_hr_data(sens.id, sens.group, sens.hr_data, sens.start_time))
    end
  end

  def extract_hr_data(id, group, encData, start_time)
    raw = Base64.decode64(encData).bytes.each_slice(2).to_a.collect{|it| it[1]*256+it[0]}
    curr_time = start_time.to_f
    last_time = curr_time
    val = []
    bufsize = 30
    tot = [0]*bufsize
    n = 0
    raw.in_groups_of(2) do |delta, hr|
      curr_time += delta/1000.0
      if curr_time-last_time > 60.0
        val.append({time: curr_time.to_i, data:tot.inject{|a,b| a+b}/bufsize.to_f})
        last_time = curr_time
      else
        if hr>0
          tot << hr
        end
        if(tot.size>bufsize)
          tot = tot.drop(1)
        end
        n += 1
      end
    end
    return([{
                       id: id,
                       tooltip: group,
                       title: 'Sensor',
                       start_time: start_time,
                       values: val,
                       evt_type: 'sensor',
                       source: 'SmartDiab'
                   }])
  end
end

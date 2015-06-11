require 'withings'

class Withings::MeasurementGroup
  def initialize(params)
    params = params.stringify_keys
    @group_id = params['grpid']
    @attribution = params['attrib']
    @taken_at = Time.at(params['date'])
    @category = params['category']
    @spo2 = nil
    params['measures'].each do |measure|
      value = (measure['value'] * 10 ** measure['unit']).to_f
      case measure['type']
        when TYPE_WEIGHT then @weight = value
        when TYPE_SIZE then @size = value
        when TYPE_FAT_MASS_WEIGHT then @fat = value
        when TYPE_FAT_RATIO then @ratio = value
        when TYPE_FAT_FREE_MASS_WEIGHT then @fat_free = value
        when TYPE_DIASTOLIC_BLOOD_PRESSURE then @diastolic_blood_pressure = value
        when TYPE_SYSTOLIC_BLOOD_PRESSURE then @systolic_blood_pressure = value
        when TYPE_HEART_PULSE then @heart_pulse = value
        when 54 then @spo2 = value
      end
    end
  end
  def spo2
    @spo2
  end
end
class Withings::User
  def getmeas(params)
    # options = {:limit => 100, :offset => 0} # this does not seem to work
    options = {}
    options.merge!(params)

    response = connection.get_request('/measure', options.merge(:action => :getmeas))
    response['measuregrps'].map do |group|
      Withings::MeasurementGroup.new(group)
    end
  end
  def getconn()
    return connection
  end
end

module SyncWithings

  Withings.consumer_key = CONNECTION_CONFIG['WITHINGS_KEY']
  Withings.consumer_secret = CONNECTION_CONFIG['WITHINGS_SECRET']

  def test_withings
    withings_conn = Connection.where(user_id: current_user.id, name: 'withings').first
    connection_data = JSON.parse(withings_conn.data)
    withings_user =  Withings::User.authenticate(connection_data['uid'], connection_data['token'], connection_data['secret'])
    dateFormat_ymd = "%Y-%m-%d"
    today_ymd = DateTime.now().strftime(dateFormat_ymd)
    sleep_data = withings_user.getconn().get_request("/v2/sleep",
                                                     {:startdateymd => '2015-06-01',
                                                      :enddateymd => '2015-06-12',
                                                      :action => "getsummary"})
    render json: sleep_data
  end


  def sync_withings
    withings_conn = Connection.where(user_id: current_user.id, name: 'withings').first
    if withings_conn
      connection_data = JSON.parse(withings_conn.data)
      begin
        withings_user =  Withings::User.authenticate(connection_data['uid'], connection_data['token'], connection_data['secret'])
        meas = sync_withings_meas(withings_user)
        act =  sync_withings_act(withings_user)
        slp = sync_withings_sleep(withings_user)

        result =  {:status=> "OK", :meas => meas, :act =>act, :sleep => slp}
      rescue Exception => e
        logger.error e.message
        logger.error e.backtrace
        result =  {:status => "ERR"}
      end
    else
      result = {:status => "ERR"}
    end

    respond_to do |format|
      format.json { render json: result}
    end
  end

  private

  def remove_activities_on_date(user_id, source, date, group=nil)
    to_remove = Summary.where("user_id= #{user_id} and source = '#{source}' and date=?", DateTime.parse(date))
    if not group.nil?
      to_remove = to_remove.where(group: group)
    end
    to_remove.each { |it| it.destroy!}

    f = Time.zone.parse(date+' 00:00:00')
    t = Time.zone.parse(date+' 23:59:59')
    sleep_to_remove = TrackerDatum.where('end_time between ? and ?', f, t).where(source: 'withings').where(group: 'sleep')
    sleep_to_remove.each { |it| it.destroy!}
  end

  def save_withings_act(rec)
    soft = rec['soft']
    moderate = rec['moderate']
    intense = rec['intense']
    isFinal = false
    if DateTime.parse(rec['date']) < Date.today()
      isFinal = true
    end
    new_act =  Summary.new( user_id: current_user.id, source: 'withings', date: DateTime.parse(rec['date']),
        total_duration: soft+moderate+intense,
        soft_duration: soft,
        moderate_duration: moderate,
        hard_duration: intense,
        distance: rec['distance'],
        steps: rec['steps'],
        calories: rec['calories'],
        elevation: rec['elevation'],
        synced_at: DateTime.now(),
        sync_final: isFinal,
        group: 'walking'
    )
    new_act.save!
  end

  def get_withings_last_sync(user_id)
    result = DateTime.parse("2010-01-01 00:00:00").to_i
    withings_meas_query = Measurement.where("user_id = #{user_id} and source = 'withings'").order(created_at: :desc).limit(1)
    if withings_meas_query.size() >0
      result = withings_meas_query[0].created_at.to_i
    end
    return result
  end

  def sync_withings_act(withings_user)
    dateFormat = "%Y-%m-%d %H:%M:%S"
    dateFormat_ymd = "%Y-%m-%d"
    today_ymd = DateTime.now().strftime(dateFormat_ymd)
    last_sync_date = get_last_synced_final_date(current_user.id, "withings")
    if last_sync_date
      start_date = last_sync_date+1.day
      act = withings_user.get_activities({:startdateymd => start_date.strftime(dateFormat_ymd), :enddateymd => today_ymd})
      for item in act['activities']
        remove_activities_on_date(current_user.id, "withings", item['date'])
        save_withings_act(item)
      end
    else
      act = withings_user.get_activities({:startdateymd => "2010-01-01", :enddateymd => today_ymd})
      for item in act['activities']
        save_withings_act(item)
      end
    end
  end

  def sync_withings_meas(withings_user)

    lastupdate = get_withings_last_sync(current_user.id)

    meas = withings_user.getmeas({ :lastupdate => lastupdate})

    for item in meas do
      measurement = Measurement.new( {
                                         :user_id => current_user.id,
                                         :source => 'withings',
                                         :date => item.taken_at,
                                         :diastolicbp => item.diastolic_blood_pressure,
                                         :systolicbp => item.systolic_blood_pressure,
                                         :pulse => item.heart_pulse,
                                         :SPO2 => item.spo2}
      )
      logger.debug measurement.to_json
      measurement.save!
    end
    return meas
  end

  def sync_withings_sleep(withings_user)
    dateFormat = "%Y-%m-%d %H:%M:%S"
    dateFormat_ymd = "%Y-%m-%d"
    today_ymd = DateTime.now().strftime(dateFormat_ymd)
    last_sync_date = get_last_synced_final_date(current_user.id, "withings", "sleep")
    if last_sync_date
      start_date = last_sync_date+1.day
      sleep_data = withings_user.getconn().get_request("/v2/sleep",
                                                       {:startdateymd => start_date.strftime(dateFormat_ymd),
                                                        :enddateymd => DateTime.now().strftime(dateFormat_ymd),
                                                        :action => "getsummary"})

      for item in sleep_data['series']
        remove_activities_on_date(current_user.id, "withings", item['date'], "sleep")
        save_withings_sleep_summary(item)
      end
    else
      sleep_data = withings_user.getconn().get_request("/v2/sleep",
                                                       {:startdateymd => "2010-01-01",
                                                        :enddateymd => DateTime.now().strftime(dateFormat_ymd),
                                                        :action => "getsummary"})

      for item in sleep_data['series']
        save_withings_sleep_summary(item)
      end
    end

    return sleep_data
  end

  def save_withings_sleep_summary(rec)
    isFinal = false
    if Time.zone.parse(rec['date']) < Date.today().midnight()
      isFinal = true
    end
    light = rec['data']['lightsleepduration']
    deep = rec['data']['deepsleepduration']
    new_sleep =  Summary.new( user_id: current_user.id, source: 'withings', date: DateTime.parse(rec['date']),
        total_duration: light+deep,
        synced_at: DateTime.now(),
        sync_final: isFinal,
        group: 'sleep'
    )
    new_sleep.save!

    puts "startdate=#{rec['startdate']} enddate=#{rec['enddate']}}"
    tracker_data = TrackerDatum.new( user_id: current_user.id, source: 'withings',
                                     start_time: Time.zone.strptime(rec['startdate'], '%s'),
                                     end_time: Time.zone.strptime(rec['enddate'], '%s'),
                                     activity:  'sleep',
                                     group: 'sleep',
                                     manual: false,
                                     duration: nil,
                                     distance: nil,
                                     steps: nil,
                                     calories: nil,
                                     synced_at: DateTime.now(),
                                     sync_final: isFinal)
    tracker_data.save!
  end

end

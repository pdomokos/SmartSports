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

Withings.consumer_key = CONNECTION_CONFIG['WITHINGS_KEY']
Withings.consumer_secret = CONNECTION_CONFIG['WITHINGS_SECRET']

class WithingsSynchronizer < SynchronizerBase
  def sync(conn)
    begin
      connection_data = JSON.parse(conn.data)
      @client =  Withings::User.authenticate(connection_data['uid'], connection_data['token'], connection_data['secret'])

      Summary.transaction do
        from = get_last_measurement_date('withings')
        from ||= DateTime.parse("2010-01-01")
        sync_withings_meas(from)

        from = get_last_summary_date('withings', 'walking')
        from ||= DateTime.parse("2010-01-01")
        sync_withings_act(from.strftime(dateFormat), DateTime.now().strftime(dateFormat))

        from = get_last_summary_date('withings', 'sleep')
        from ||= DateTime.parse("2010-01-01")
        sync_withings_sleep(from)
      end

      return true
    rescue Exception => e
      logger.error("Withings sync failed for user: #{connection_data['uid']}")
      logger.error(e.message )
      logger.error(e.backtrace.join("\n") )
      return false
    end
  end

  private

  # def remove_activities_on_date(source, date, group=nil)
  #   to_remove = Summary.where("user_id= #{user_id} and source = '#{source}' and date>=? and date<?",
  #                             Date.parse(date).midnight, Date.parse(date).midnight+1.day)
  #   if not group.nil?
  #     to_remove = to_remove.where(group: group)
  #   end
  #   n = to_remove.delete_all
  #   logger.info("deleted #{n} summaries, user_id=#{user_id}")

    # f = Time.zone.parse(date+' 00:00:00')
    # t = Time.zone.parse(date+' 23:59:59')
    # sleep_to_remove = TrackerDatum.where('end_time between ? and ?', f, t).where(source: 'withings').where(group: 'sleep')
    # sleep_to_remove.each { |it| it.destroy!}
  # end

  def sync_withings_act(from, to)
    deleted = remove_summaries_from_date("withings", from, 'walking')
    logger.info("deleted #{deleted} walk summaries")
    act = client.get_activities({:startdateymd => from, :enddateymd => to})
    logger.info("adding #{act['activities'].size()} walk summaries")
    for item in act['activities']
      save_withings_act(item)
    end
  end

  def save_withings_act(rec)
    soft = rec['soft']
    moderate = rec['moderate']
    intense = rec['intense']

    new_act =  Summary.new( user_id: user_id, source: 'withings', date: DateTime.parse(rec['date']),
                            total_duration: soft+moderate+intense,
                            soft_duration: soft,
                            moderate_duration: moderate,
                            hard_duration: intense,
                            distance: rec['distance'],
                            steps: rec['steps'],
                            calories: rec['calories'],
                            elevation: rec['elevation'],
                            synced_at: DateTime.now(),
                            group: 'walking'
    )
    new_act.save!
  end

  def sync_withings_meas(from)
    lastUpdateTs = from.to_i
    deleted = remove_measurements_from_date('withings', from.strftime(dateFormat))
    logger.info("deleted #{deleted} meas")
    meas = client.getmeas({ :lastupdate => lastUpdateTs})
    logger.info("adding #{meas.size()} meas")
    for item in meas do
      measurement = Measurement.new( {
                                         :user_id => user_id,
                                         :source => 'withings',
                                         :date => item.taken_at,
                                         :diastolicbp => item.diastolic_blood_pressure,
                                         :systolicbp => item.systolic_blood_pressure,
                                         :pulse => item.heart_pulse,
                                         :SPO2 => item.spo2}
      )
      measurement.save!
    end
  end

  def sync_withings_sleep(from)
    deleted = remove_summaries_from_date( "withings", from.strftime(dateFormat), "sleep")
    logger.info("deleted #{deleted} sleep summaries")

    today=DateTime.now().midnight+1.day
    to = from+199.days
    while to<today
      import_sleep_items(from, to)
      from = to
      to = to+199.days
    end
    to = DateTime.now()
    import_sleep_items(from, to)
  end

  def import_sleep_items(from, to)
    sleep_data = client.getconn().get_request("/v2/sleep",
                                                     {:startdateymd => from.strftime(dateFormat),
                                                      :enddateymd => to.strftime(dateFormat),
                                                      :action => "getsummary"})
    logger.info("adding #{sleep_data['series'].size()} sleep summaries")
    for item in sleep_data['series']
      save_withings_sleep_summary(item)
    end
  end

  def save_withings_sleep_summary(rec)
    light = rec['data']['lightsleepduration']
    deep = rec['data']['deepsleepduration']
    new_sleep =  Summary.new( user_id: user_id, source: 'withings', date: DateTime.parse(rec['date']),
                              total_duration: light+deep,
                              synced_at: DateTime.now(),
                              group: 'sleep'
    )
    new_sleep.save!

    # tracker_data = TrackerDatum.new( user_id: user_id, source: 'withings',
    #                                  start_time: Time.zone.strptime(rec['startdate'], '%s'),
    #                                  end_time: Time.zone.strptime(rec['enddate'], '%s'),
    #                                  activity:  'sleep',
    #                                  group: 'sleep',
    #                                  manual: false,
    #                                  duration: nil,
    #                                  distance: nil,
    #                                  steps: nil,
    #                                  calories: nil,
    #                                  synced_at: DateTime.now(),
    #                                  sync_final: isFinal)
    # tracker_data.save!
  end
end
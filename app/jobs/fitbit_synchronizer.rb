class FitbitSynchronizer < SynchronizerBase
  require 'json'

  def sync(conn)
    begin
      connection_data = JSON.parse(conn.data)
      @client = Fitgem::Client.new(:token => connection_data['token'],
                                  :secret => connection_data['secret'],
                                  :consumer_key => CONNECTION_CONFIG['FITBIT_KEY'],
                                  :consumer_secret => CONNECTION_CONFIG['FITBIT_SECRET'])
      userinfo = client.user_info
      member_since = userinfo['user']['memberSince']

      from = get_last_summary_date("fitbit", "walking")
      from ||= DateTime.parse(member_since)

      remove_summaries_from_date("fitbit", from.strftime(dateFormat), "walking")
      to = DateTime.now()
      logger.info("saving fitbit: #{from.strftime(dateFormat)} - #{to.strftime(dateFormat)}")
      act = client.activity_on_date_range("steps", from.strftime(dateFormat), to.strftime(dateFormat))
      saved = 0
      for item in act["activities-steps"]
        saved += save_fitbit_daily_steps(item["dateTime"], item["value"].to_i)
      end
      logger.info("saved #{saved} records")
      return true
    rescue Exception => e
      logger.error("Fitbit sync failed for user: #{connection_data['uid']}")
      logger.error(e.message )
      logger.error(e.backtrace.join("\n") )
      return false
    end
  end

  private

  def save_fitbit_act(rec, date)

    summary = rec['summary']
    lightly = summary['lightlyActiveMinutes']
    very = summary['veryActiveMinutes']
    fairly = summary['fairlyActiveMinutes']
    total = lightly+very+fairly
    distance_total = summary['distances'].select { |it| it['activity']=='total' }
    distance_total = distance_total[0]['distance']
    if distance_total >0.0 and summary['steps']>0
      isFinal = false
      if date < Date.today()
        isFinal = true
      end
      new_act = Summary.new(user_id: user_id, source: 'fitbit', date: date,
                            total_duration: total,
                            soft_duration: lightly,
                            moderate_duration: fairly,
                            hard_duration: very,
                            distance: distance_total,
                            steps: summary['steps'],
                            calories: summary['activityCalories'],
                            elevation: summary['elevation'],
                            synced_at: DateTime.now(),
                            sync_final: isFinal
      )
      new_act.save!
      return true
    else
      return false
    end
  end

  def save_fitbit_daily_steps(dateTime, steps)

    if steps>0
      new_act = Summary.new(user_id: user_id,
                            source: 'fitbit',
                            date: dateTime,
                            steps: steps,
                            synced_at: DateTime.now(),
                            group: 'walking'
      )
      new_act.save!
      return 1
    end
    return 0
  end

end
class FitbitSynchronizer < SynchronizerBase
  require 'json'

  def sync()
    begin
      connection_data = JSON.parse(Connection.find(connection_id).data)
      client = Fitgem::Client.new(:token => connection_data['token'], :secret => connection_data['secret'], :consumer_key => CONNECTION_CONFIG['FITBIT_KEY'], :consumer_secret => CONNECTION_CONFIG['FITBIT_SECRET'])
      userinfo = client.user_info
      member_since = userinfo['user']['memberSince']
      dateFormat = "%Y-%m-%d"
      now = DateTime.now()
      saved = []
      last_synced = get_last_synced_final_date("fitbit")
      if !last_synced
        currdate = Date.parse(member_since)
        activities = client.activity_on_date_range("steps", currdate, now.strftime(dateFormat))
        dailyacts = activities['activities-steps']
        dailyacts.each do |d|
          if d['value'] != "0"
            save_fitbit_daily_steps(d['dateTime'], d['value'])
          end
        end
      else
        currdate = last_synced+1.day
        while currdate <= now
          act = client.activities_on_date(currdate)
          remove_activities_on_date("fitbit", currdate.strftime(dateFormat))
          if save_fitbit_act(act, currdate)
            saved.push(act)
          end
          currdate = currdate+1.day
        end
      end

    rescue Exception => e
      logger.error("Fitibit sync failed for user: #{connection_data['uid']}")
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
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
    isFinal = false
    date = Date.parse(dateTime)
    if date < Date.today()
      isFinal = true
    end
    new_act = Summary.new(user_id: user_id,
                          source: 'fitbit',
                          date: date,
                          steps: steps,
                          synced_at: DateTime.now(),
                          sync_final: isFinal
    )
    new_act.save!
  end

  def remove_activities_on_date(source, date, group=nil)
    to_remove = Summary.where("user_id= #{user_id} and source = '#{source}' and date=?", DateTime.parse(date))
    if not group.nil?
      to_remove = to_remove.where(group: group)
    end
    to_remove.each { |it| it.destroy! }
  end

end
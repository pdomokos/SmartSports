class MisfitSynchronizer < SynchronizerBase

  def sync()
    begin
      consumer_key = CONNECTION_CONFIG['MISFIT_KEY']
      consumer_secret = CONNECTION_CONFIG['MISFIT_SECRET']
      connection_data = JSON.parse(Connection.find(connection_id).data)
      client ||= MisfitGem::Client.new(
          consumer_key: consumer_key,
          consumer_secret: consumer_secret,
          token: connection_data['token']
      )
      dateFormat_ymd = "%Y-%m-%d"
      today_ymd = DateTime.now().strftime(dateFormat_ymd)
      today_minus_28_ymd = (DateTime.now()-28.days).strftime(dateFormat_ymd)
      last_sync_date = get_last_synced_final_date("misfit")
      if last_sync_date
        start_date = last_sync_date+1.day
        act = client.get_summary(start_date: start_date.strftime(dateFormat_ymd), end_date: today_ymd, detail: true)
        if not act.nil?
          for item in act['summary']
            remove_activities_on_date("misfit", item['date'])
            save_misfit_act(item)
          end
        end
      else
        logger.info "sync misfit summary: #{today_minus_28_ymd}, #{today_ymd}"
        act = client.get_summary(start_date: today_minus_28_ymd, end_date: today_ymd, detail: true)
        if not act.nil?
          for item in act['summary']
            save_misfit_act(item)
          end
        end
      end

    rescue Exception => e
      logger.error("Misfit sync failed for user: #{connection_data['uid']}")
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
    end
  end

  private

  def save_misfit_act(rec)
    isFinal = false
    if DateTime.parse(rec['date']) < Date.today()
      isFinal = true
    end

    new_act =  Summary.new( user_id: user_id,
                            source: 'misfit',
                            date: DateTime.parse(rec['date']),
                            distance: rec['distance'],
                            steps: rec['steps'],
                            calories: rec['calories'],
                            synced_at: DateTime.now(),
                            sync_final: isFinal,
                            group: 'walking'
    )
    new_act.save!
  end

end
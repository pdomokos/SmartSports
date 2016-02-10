class MisfitSynchronizer < SynchronizerBase

  def sync(conn)
    begin
      consumer_key = CONNECTION_CONFIG['MISFIT_KEY']
      consumer_secret = CONNECTION_CONFIG['MISFIT_SECRET']
      connection_data = JSON.parse(conn.data)
      @client ||= MisfitGem::Client.new(
          consumer_key: consumer_key,
          consumer_secret: consumer_secret,
          token: connection_data['token']
      )

      today = DateTime.now()

      from = get_last_summary_date('misfit', 'walking')
      from ||= DateTime.now()-1.year

      remove_summaries_from_date("misfit", from.strftime(dateFormat), "walking")
      to = from+28.days
      while to<today
        import_summaries(from, to)
        from = to
        to = to+28.days
      end
      if from<today.midnight+1.day
        to = today.midnight+1.day
        import_summaries(from, to)
      end
      return true

    rescue Exception => e
      logger.error("Misfit sync failed for user: #{connection_data['uid']}")
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      return false
    end
  end

  private

  def import_summaries(from, to)
    logger.info("saving: #{from.strftime(dateFormat)} - #{to.strftime(dateFormat)}")
    act = client.get_summary(start_date: from.strftime(dateFormat), end_date: to.strftime(dateFormat), detail: true)
    for item in act['summary']
      save_misfit_act(item)
    end
  end
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
class MovesSynchronizer < SynchronizerBase

  def sync(conn)
    begin
      connection_data = JSON.parse(conn.data)
      @client = Moves::Client.new(connection_data["token"])

      profile = client.profile['profile']
      @timezone = ActiveSupport::TimeZone.new(profile['currentTimeZone']['id'])

      synced_at = conn.synced_at
      last_sum = get_last_summary_date('moves')
      from = last_sum
      if !synced_at.nil? and !last_sum.nil? and synced_at>last_sum
        from = synced_at
      end
      from ||= timezone.parse(profile['firstDate'])

      added = do_sync_moves(from)
      logger.info("moves added #{added} summary records")

      # no daily storyline for now..
      # status_tracker = do_sync_moves_tracker(connection_data)
      return true
    rescue Exception => e
      logger.error("Moves sync failed for user: #{connection_data['uid']}")
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      return false
    end
  end

  private

  def do_sync_moves(from)

    remove_summaries_from_date("moves", from.strftime(dateFormat))

    total = 0
    today = DateTime.now()
    to = from+30.days
    while to<today
      total += import_summaries(from, to)
      from = to+1.day
      to = from+30.days
    end
    if from<today.midnight
      to = today
      total += import_summaries(from, to)
    end


    return total
  end

  def import_summaries(from, to)
    total = 0
    summaries = client.daily_summary(from..to)
    for summary in summaries do
      currDate = timezone.parse(summary["date"])
      unless  summary["summary"].nil?
        for rec in summary["summary"] do

          act = Summary.new(user_id: user_id, source: 'moves', date: currDate, activity: rec['activity'], group: rec['group'],
                            total_duration: rec['duration'],
                            distance: rec['distance'],
                            steps: rec['steps'].to_i,
                            calories: rec['calories'],
                            synced_at: DateTime.now())
          act.save!
          # logger.info("adding: #{act.id} on #{currDate}, from=#{from}")
          total += 1
        end
      end
    end
    logger.info("moves adding #{total} records #{from.strftime(dateFormat)} - #{to.strftime(dateFormat)}")
    return total
  end

  def remove_tracker_data_not_final(source)
    to_remove = TrackerDatum.where("user_id= #{user_id} and source = '#{source}' and sync_final = 'f'")
    to_remove.each { |it| it.destroy! }
  end

  def do_sync_moves_tracker()
    profile = client.profile['profile']
    remove_tracker_data_not_final("moves")
    currDate = get_last_synced_tracker_final_date("moves")
    if currDate
      currDate = Date.parse(currDate)+1.day
    else
      currDate = Date.parse(profile['firstDate'])
    end
    today = Date.today()
    while currDate <= today
      logger.info "syncing #{currDate}"
      currDateYmd = currDate.strftime(dateFormat)
      storyline = client.daily_storyline(currDateYmd)
      for item in storyline
        if item['segments']
          segments = item['segments']
          for sItem in segments
            isFinal = false
            if currDate < today
              isFinal = true
            end
            if sItem['type'] == 'move'
              activities = sItem['activities']
              for aItem in activities
                if aItem['activity']!='transport'
                  tracker_data = TrackerDatum.new(user_id: user_id, source: 'moves',
                                                  start_time: aItem['startTime'],
                                                  end_time: aItem['endTime'],
                                                  activity: aItem['activity'],
                                                  group: aItem['group'],
                                                  manual: aItem['manual'],
                                                  duration: aItem['duration'],
                                                  distance: aItem['distance'],
                                                  steps: aItem['steps'].to_i,
                                                  calories: aItem['calories'],
                                                  synced_at: DateTime.now(),
                                                  sync_final: isFinal
                  )
                  tracker_data.save!
                end
              end
            end
          end
        else
          logger.info "no segments for #{currDate}"
        end
      end

      currDate = currDate+1.day
    end
    return "OK"
  end

end
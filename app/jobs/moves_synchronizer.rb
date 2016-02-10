class MovesSynchronizer < SynchronizerBase

  def sync(conn)
    begin
      connection_data = JSON.parse(conn.data)
      status = do_sync_moves(connection_data)
      status_tracker = do_sync_moves_tracker(connection_data)
      return true
    rescue Exception => e
      logger.error("Moves sync failed for user: #{connection_data['uid']}")
      logger.error(e.message)
      logger.error(e.backtrace.join("\n"))
      return false
    end
  end

  private

  def do_sync_moves(sess)
    dateFormat = "%Y-%m-%d"
    @moves = Moves::Client.new(sess["token"])
    @profile = @moves.profile['profile']
    currDate = get_last_synced_final_date("moves")
    if currDate
      currDate = currDate+1.day
    else
      currDate = Date.parse(@profile['firstDate'])
    end
    today = Date.today()
    todayYmd = today.strftime(dateFormat)
    while currDate <= today
      dbActivities = Summary.where("user_id= #{user_id} and source = 'moves' and (date between '#{currDate} 00:00:00' and '#{currDate} 23:59:59' )")
      if !dbActivities.all? { |a| a.sync_final }
        dbActivities.each { |a| a.destroy }
        dbActivities = nil
      end
      if dbActivities.nil? or dbActivities.size == 0
        logger.info "syncing #{currDate}"
        currDateYmd = currDate.strftime(dateFormat)
        summary = @moves.daily_summary(currDateYmd)
        for item in summary do
          if item['summary']
            lastUpdate = item['lastUpdate']
            sItem = item['summary']
            isFinal = false
            logger.info "currdate="+currDate.to_s
            logger.info "today="+today.to_s
            if currDate < today
              isFinal = true
            end
            i = 0
            for rec in sItem do
              act = Summary.new(user_id: user_id, source: 'moves', date: currDate, activity: rec['activity'], group: rec['group'],
                                total_duration: rec['duration'],
                                distance: rec['distance'],
                                steps: rec['steps'].to_i,
                                calories: rec['calories'],
                                synced_at: DateTime.now(),
                                sync_final: isFinal
              )
              act.save!
              i = i + 1
            end
          else
            logger.info "no activities for #{currDate}"
          end
        end
      end

      currDate = currDate+1.day
    end
    return "OK"
  end

  def remove_tracker_data_not_final(source)
    to_remove = TrackerDatum.where("user_id= #{user_id} and source = '#{source}' and sync_final = 'f'")
    to_remove.each { |it| it.destroy! }
  end

  def do_sync_moves_tracker(sess)
    dateFormat = "%Y-%m-%d"
    @moves = Moves::Client.new(sess["token"])
    @profile = @moves.profile['profile']
    remove_tracker_data_not_final("moves")
    currDate = get_last_synced_tracker_final_date("moves")
    if currDate
      currDate = Date.parse(currDate)+1.day
    else
      currDate = Date.parse(@profile['firstDate'])
    end
    today = Date.today()
    while currDate <= today
      logger.info "syncing #{currDate}"
      currDateYmd = currDate.strftime(dateFormat)
      storyline = @moves.daily_storyline(currDateYmd)
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
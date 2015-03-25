module SyncMisfit

  def test_misfit
    misfit_conn = Connection.where(user_id: current_user.id, name: 'misfit').first
    if misfit_conn
      connection_data = JSON.parse(misfit_conn.data)

      client ||= MisfitGem::Client.new(
          consumer_key: CONNECTION_CONFIG['MISFIT_KEY'],
          consumer_secret: CONNECTION_CONFIG['MISFIT_SECRET'],
          token: connection_data['token']
      )
      userinfo = client.get_profile
      render json: {:status => status, :profile => userinfo}
    end
  end

  def misfit_destroy
    misfit_conn = Connection.where(user_id: current_user.id, name: 'misfit').first
    if misfit_conn
      misfit_conn.destroy!
    end
    redirect_to pages_settings_path
  end

  def sync_misfit
    consumer_key = CONNECTION_CONFIG['MISFIT_KEY']
    consumer_secret = CONNECTION_CONFIG['MISFIT_SECRET']

    misfit_conn = Connection.where(user_id: current_user.id, name: 'misfit').first
    if misfit_conn
      connection_data = JSON.parse(misfit_conn.data)

      client ||= MisfitGem::Client.new(
          consumer_key: consumer_key,
          consumer_secret: consumer_secret,
          token: connection_data['token']
      )
      # userinfo = client.get_profile
      # device = client.get_device
      # summary = client.get_summary(start_date: Date.today - 1.week, end_date: Date.today, detail: true)
      # sessions = client.get_sessions(start_date: Date.today - 1.week, end_date: Date.today)
      #summary = client.get_summary(start_date: "2015-03-23", end_date: "2015-03-26", detail: true)
      #render json: summary
      #return
      # session = client.get_session(id: "5511b6f12f5a1f6647000009")
      # sleeps = client.get_sleeps(start_date: Date.today - 1.week, end_date: Date.today)
      # render json: {:status => status, :profile => userinfo, :device => device, :summary => summary, :sessions => sessions, :session => session, :sleeps => sleeps}
      #dateFormat = "%Y-%m-%d %H:%M:%S"

      dateFormat_ymd = "%Y-%m-%d"
      today_ymd = DateTime.now().strftime(dateFormat_ymd)
      today_minus_28_ymd = (DateTime.now()-28.days).strftime(dateFormat_ymd)
      last_sync_date = get_last_synced_final_date(current_user.id, "misfit")
      if last_sync_date
        start_date = last_sync_date+1.day
        act = client.get_summary(start_date: start_date.strftime(dateFormat_ymd), end_date: today_ymd, detail: true)
        if not act.nil?
          for item in act['summary']
            remove_activities_on_date(current_user.id, "misfit", item['date'])
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

      render json: {:status => "OK"}
    else
      render json: {:status => "ERR"}
    end

  end

  private

  def save_misfit_act(rec)
    isFinal = false
    if DateTime.parse(rec['date']) < Date.today()
      isFinal = true
    end

    new_act =  Summary.new( user_id: current_user.id,
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
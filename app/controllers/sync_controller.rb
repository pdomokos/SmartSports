require 'Withings'

class SyncController < ApplicationController

  Withings.consumer_key = APP_CONFIG['WITHINGS_KEY']
  Withings.consumer_secret = APP_CONFIG['WITHINGS_SECRET']

  def sync_moves
    movesconn = Connection.where(user_id: current_user.id, name: 'moves').first
    if movesconn != nil
      sess = JSON.parse(movesconn.data)
    else
      auth = request.env['omniauth.auth']
      current_user.connection.create(name: 'moves', data: auth['credentials']['token'], user_id: current_user.id )
      current_user.save(validate: false)
      sess = { "access_token" => auth['credentials']['token']}
    end
    status = do_sync_moves(sess)

    respond_to do |format|
      format.json { render json: {:status => status}}
    end
  end

  def sync_withings

    withings_conn = Connection.where(user_id: current_user.id, name: 'withings').first
    if withings_conn
      connection_data = JSON.parse(withings_conn.data)
      result = do_sync_withings(connection_data)
      result.merge!({:status => "OK"})
    else
      result = {:status => "ERR" }
    end
    respond_to do |format|
      format.json { render json: result}
    end
  end

  def sync_fitbit
    dateFormat = "%Y-%m-%d"
    fitbit_conn = Connection.where(user_id: current_user.id, name: 'fitbit').first
    if fitbit_conn
      connection_data = JSON.parse(fitbit_conn.data)
      client = Fitgem::Client.new(:token => connection_data['token'], :secret => connection_data['secret'],
                                  :consumer_key => APP_CONFIG['FITBIT_KEY'], :consumer_secret => APP_CONFIG['FITBIT_SECRET'])
      userinfo = client.user_info
      member_since = userinfo['user']['memberSince']

      now = DateTime.now()
      saved = []
      last_synced = get_last_synced_final_date(current_user.id, "fitbit")
      if !last_synced
        currdate = Date.parse(member_since)
      else
        currdate = last_synced+1.day
      end
      while currdate <= now
        act = client.activities_on_date(currdate)
        remove_activities_on_date(current_user.id, "fitbit", currdate.strftime(dateFormat))
        if save_fitbit_act(act, currdate)
          saved.push(act)
        end
        currdate = currdate+1.day
      end

      result = { :status => "OK", :act => saved}
    else
      result = { :status => "ERR"}
    end
    respond_to do |format|
      format.json { render json: result}
    end
  end

  private

  def do_sync_moves(sess)
    dateFormat = "%Y-%m-%d"
    @moves = Moves::Client.new(sess["token"])
    @profile = @moves.profile['profile']
    puts @profile
    currDate = Date.parse(@profile['firstDate'])
    today = Date.today()
    todayYmd = today.strftime(dateFormat)
    while currDate <= today
      dbActivities = Activity.where("user_id= #{current_user.id} and source = 'moves' and (date between '#{currDate} 00:00:00' and '#{currDate} 23:59:59' )")
      if !dbActivities.all? { |a| a.sync_final }
        dbActivities.each { |a| a.destroy }
        dbActivities = nil
      end
      if dbActivities.nil? or dbActivities.size == 0
        puts "syncing #{currDate}"
        currDateYmd = currDate.strftime(dateFormat)
        summary = @moves.daily_summary(currDateYmd)
        for item in summary do
          if item['summary']
            lastUpdate = item['lastUpdate']
            sItem = item['summary']
            isFinal = false
            puts "currdate="+currDate.to_s
            puts "today="+today.to_s
            if currDate < today
              isFinal = true
            end
            i = 0
            for rec in sItem do
              puts "rec[#{i}]=#{rec}"
              act = Activity.new( user_id: current_user.id, source: 'moves', date: currDate, activity:  rec['activity'], group: rec['group'],
                  total_duration: rec['duration'],
                  distance: rec['distance'],
                  steps: rec['steps'],
                  calories: rec['calories'],
                  synced_at: DateTime.now(),
                  sync_final: isFinal
              )
              act.save!
              puts "saved #{i} to db"
              i = i + 1
            end
          else
            puts "no activities for #{currDate}"
          end
        end
      else
        puts "exists #{currDate}"
      end

      currDate = currDate+1.day
    end
    return "OK"
  end

  def do_sync_withings(connection_data)
    dateFormat = "%Y-%m-%d %H:%M:%S"
    dateFormat_ymd = "%Y-%m-%d"
    withings_user =  Withings::User.authenticate(connection_data['uid'], connection_data['token'], connection_data['secret'])
    meas = withings_user.measurement_groups(:end_at => Time.now)
    for item in meas do
      currDate = item.taken_at.strftime(dateFormat)
      t1 = currDate.to_datetime
      if Measurement.where("user_id=#{current_user.id} and date = :taken_at",{taken_at: t1}).size == 0
        measurement = Measurement.new( user_id: current_user.id, source: 'withings', date: t1, diastolicbp: item.diastolic_blood_pressure, systolicbp: item.systolic_blood_pressure, pulse: item.heart_pulse )
        measurement.save!
        puts 'item saved'
      end
    end

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

    return act
  end

  private

  def remove_activities_on_date(user_id, source, date)
    to_remove = Activity.where("user_id= #{user_id} and source = '#{source}' and date=?", DateTime.parse(date))
    to_remove.each { |it| it.destroy!}
  end

  def get_last_synced_final_date(user_id, source)
    last_sync_date = nil
    query = Activity.where("user_id= #{user_id} and source = '#{source}'")
    if  query.size() > 0
      last_sync = query.where("sync_final = 't'").order(date: :desc).limit(1)[0]
      last_sync_date = last_sync.date
    end
    return last_sync_date
  end

  def save_withings_act(rec)
    soft = rec['soft']
    moderate = rec['moderate']
    intense = rec['intense']
    isFinal = false
    if DateTime.parse(rec['date']) < Date.today()
      isFinal = true
    end
    new_act =  Activity.new( user_id: current_user.id, source: 'withings', date: DateTime.parse(rec['date']),
        total_duration: soft+moderate+intense,
        soft_duration: soft,
        moderate_duration: moderate,
        hard_duration: intense,
        distance: rec['distance'],
        steps: rec['steps'],
        calories: rec['calories'],
        elevation: rec['elevation'],
        synced_at: DateTime.now(),
        sync_final: isFinal
    )
    new_act.save!
  end

  def save_fitbit_act(rec, date)

    summary = rec['summary']
    lightly = summary['lightlyActiveMinutes']
    very = summary['veryActiveMinutes']
    fairly = summary['fairlyActiveMinutes']
    total = lightly+very+fairly
    distance_total = summary['distances'].select { |it| it['activity']=='total'}
    distance_total = distance_total[0]['distance']
    if distance_total >0.0 and summary['steps']>0
      isFinal = false
      if date < Date.today()
        isFinal = true
      end
      new_act =  Activity.new( user_id: current_user.id, source: 'fitbit', date: date,
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

end

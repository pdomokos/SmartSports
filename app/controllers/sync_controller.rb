class SyncController < ApplicationController
  def sync_moves
    movesconn = Connection.where(user_id: current_user.id, name: 'moves').first
    if movesconn != nil
      sess = { "access_token" => movesconn.data}
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
    connection_data = JSON.parse(withings_conn.data)
    if withings_conn
      withings_user =  Withings::User.authenticate(connection_data['uid'], connection_data['acc_key'], connection_data['acc_secret'])
      meas = withings_user.measurement_groups(:per_page => 10, :page => 1, :end_at => Time.now)
      result = { :status => "OK", :activities => withings_user.get_activities(), :meas => meas}
      # TODO save to database
    else
      result = { :status => "ERR"}
    end
    respond_to do |format|
      format.json { render json: result}
    end
  end

  def sync_fitbit
    fitbit_conn = Connection.where(user_id: current_user.id, name: 'fitbit').first
    connection_data = JSON.parse(fitbit_conn.data)
    if fitbit_conn
      client = Fitgem::Client.new(:token => connection_data['token'], :secret => connection_data['secret'], :consumer_key => ENV['FITBIT_KEY'], :consumer_secret => ENV['FITBIT_SECRET'])
      userinfo = client.user_info
      result = { :status => "OK", :userinfo => userinfo}
      # TODO save to database
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
    @moves = Moves::Client.new(sess["access_token"])
    @profile = @moves.profile['profile']
    puts @profile
    currDate = Date.parse(@profile['firstDate'])
    today = Date.today()
    while currDate < today
      if Activity.where("user_id= #{current_user.id} and (date between '#{currDate} 00:00:00' and '#{currDate} 23:59:59' )").size == 0
        puts "syncing #{currDate}"
        summary = @moves.daily_summary(currDate.strftime(dateFormat))
        for item in summary do
          if item['summary']
            lastUpdate = item['lastUpdate']
            sItem = item['summary']
            i = 0
            for rec in sItem do
              puts "rec[#{i}]=#{rec}"
              act = Activity.new( user_id: current_user.id, source: 'moves', date: currDate, activity:  rec['activity'], group: rec['group'], duration: rec['duration'],
                  distance: rec['distance'], steps: rec['steps'], last_update: lastUpdate)
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

end

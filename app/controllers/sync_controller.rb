class SyncController < ApplicationController
  def sync_moves

    if current_user.connection_id != nil
      sess = { "access_token" => Connection.find(current_user.connection_id).data}
    else
      auth = request.env['omniauth.auth']
      conn = Connection.new
      conn.name = 'moves'
      #TODO strore full auth_hash string in connection.data, not only moves access token
      #conn.data = auth.inspect
      conn.data = auth['credentials']['token']
      conn.save!
      current_user.connection_id = conn.id
      current_user.save(validate: false)

      sess = { "access_token" => auth['credentials']['token']}
    end
    status = do_sync_moves(sess)

    respond_to do |format|
      format.json { render json: {:status => status}}
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

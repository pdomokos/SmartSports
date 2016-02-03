module SyncMoves

  def sync_moves
    moves_conn = Connection.where(user_id: current_user.id, name: 'moves').first
    if moves_conn
      Delayed::Job.enqueue SyncConnectionJob.new(:moves, current_user.id, moves_conn.id)
      result = {:status => "OK"}
    else
      result = {:status => "ERR"}
    end

    respond_to do |format|
      format.json { render json: result }
    end
  end

  def sync_moves_act_daily
    movesconn = Connection.where(user_id: current_user.id, name: 'moves').first
    if movesconn != nil
      sess = JSON.parse(movesconn.data)

      @moves = Moves::Client.new(sess["token"])
      today = Date.today()
      dateFormat = "%Y-%m-%d"
      todayYmd = today.strftime(dateFormat)
      daily = @moves.daily_activities(todayYmd)
      status = "OK"
    else
      status = "NOK"
    end
    respond_to do |format|
      format.json { render json: {:status => status, :data => daily} }
    end
  end

end
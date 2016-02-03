module SyncFitbit

  def sync_fitbit
    fitbit_conn = Connection.where(user_id: current_user.id, name: 'fitbit').first
    if fitbit_conn
      Delayed::Job.enqueue SyncConnectionJob.new(:fitbit, current_user.id, fitbit_conn.id)
      result = {:status => "OK"}
    else
      result = {:status => "ERR"}
    end

    respond_to do |format|
      format.json { render json: result }
    end
  end

end
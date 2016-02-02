module SyncGoogle

  def sync_google
    google_conn = Connection.where(user_id: current_user.id, name: 'google').first
    if google_conn
      Delayed::Job.enqueue SyncConnectionJob.new(:google, current_user.id, google_conn.id)
      result = {:status => "OK"}
    else
      result = {:status => "ERR"}
    end

    respond_to do |format|
      format.json { render json: result }
    end
  end

 end
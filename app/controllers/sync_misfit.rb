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

  def sync_misfit
    misfit_conn = Connection.where(user_id: current_user.id, name: 'misfit').first
    if misfit_conn
      Delayed::Job.enqueue SyncConnectionJob.new(:misfit, current_user.id, misfit_conn.id)
      result = {:status => "OK"}
    else
      result = {:status => "ERR"}
    end

    respond_to do |format|
      format.json { render json: result }
    end
  end

end
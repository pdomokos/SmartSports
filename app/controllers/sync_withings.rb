
module SyncWithings

  def test_withings
    withings_conn = Connection.where(user_id: current_user.id, name: 'withings').first
    connection_data = JSON.parse(withings_conn.data)
    withings_user =  Withings::User.authenticate(connection_data['uid'], connection_data['token'], connection_data['secret'])

    data = withings_user.getconn().get_request("/v2/measure",
                                                     {:startdate => Time.zone.now.midnight.to_i,
                                                      :enddate => (Time.zone.now.midnight+1.day).to_i,
                                                      :action => "getintradayactivity"})
    render json: data
  end

  def sync_withings
    withings_conn = Connection.where(user_id: current_user.id, name: 'withings').first
    if withings_conn
      Delayed::Job.enqueue SyncConnectionJob.new(:withings, current_user.id, withings_conn.id)
      result =  {:status=> "OK"}
    else
      result = {:status => "ERR"}
    end

    respond_to do |format|
      format.json { render json: result}
    end
  end

end

module SyncGoogle
   require "net/https"
   require "uri"

  def sync_google
    google_conn = Connection.where(user_id: current_user.id, name: 'google').first
    if google_conn
      connection_data = JSON.parse(google_conn.data)
      @access_token = connection_data["token"] # only works if not expired
      @refresh_token = connection_data["refresh_token"]
      res = query_steps()
      response = res[0]
      startTime = res[1].to_i
      jsonarr = JSON.parse(response.body)
      #<Net::HTTPUnauthorized:0x00000003c82f50>
      #{"error"=>{"errors"=>[{"domain"=>"global", "reason"=>"authError", "message"=>"Invalid Credentials", "locationType"=>"header", "location"=>"Authorization"}], "code"=>401, "message"=>"Invalid Credentials"}}
      if jsonarr["error"] != nil
        errorcode = jsonarr["error"]["code"]
        if errorcode && errorcode.to_i == 401
          refresh_token(google_conn)
          res = query_steps()
          response = res[0]
          startTime = res[1].to_i
          jsonarr = JSON.parse(response.body)
        end
      end

      sync_data(jsonarr, startTime)

      result = { :status => "OK"}
    else
      result = { :status => "ERR"}
    end
    respond_to do |format|
      format.json { render json: result}
    end
  end

private

  def remove_summary_not_final(user_id, source)
     to_remove = Summary.where("user_id= #{user_id} and source = '#{source}' and sync_final = 'f'")
     to_remove.each { |it| it.destroy!}
  end


  def sync_data(jsonarr, startTime)
    #hash format:
    # {"minStartTimeNs"=>"1252459233011941709", "maxEndTimeNs"=>"1422459233011941709", "dataSourceId"=>"derived:com.google.step_count.delta:com.google.android.gms:estimated_steps",
    #  "point"=>[{"startTimeNanos"=>"1418161226385000000", "endTimeNanos"=>"1418161230036397705", "dataTypeName"=>"com.google.step_count.delta", "originDataSourceId"=>"raw:com.google.step_count.cumulative:LGE:Nexus 5:a1b2971:Step Counter", "value"=>[{"intVal"=>5}], "modifiedTimeMillis"=>"1418163702486"},
    #            {"startTimeNanos"=>"

    remove_summary_not_final(current_user.id, 'google')
    puts 'after remove not final summary'
    oneDayNanos = 8.64 * (10 ** 13)
    dataPoints = jsonarr["point"]
    minStartTimeNs = jsonarr["minStartTimeNs"].to_i
    startTimeNanos = minStartTimeNs
    total_duration = 0
    steps = 0
   
    dataPoints.each do |datapoint|
      if newDayData(startTime, startTimeNanos, datapoint["startTimeNanos"].to_i, oneDayNanos)
        if steps != 0
          date = getDateOfSummary(startTime, startTimeNanos, oneDayNanos)
          saveSummary(steps, date, total_duration, true)
          puts 'save final'
        end
        valueArr = datapoint["value"]
        startTimeNanos = datapoint["startTimeNanos"].to_i
        endTimeNanos = datapoint["endTimeNanos"].to_i
        duration = (endTimeNanos - startTimeNanos) / (10 ** 9).to_f
        total_duration = duration
        steps = valueArr[0]["intVal"]
      else
        valueArr = datapoint["value"]
        startTimeNanos = datapoint["startTimeNanos"].to_i
        endTimeNanos = datapoint["endTimeNanos"].to_i
        duration = (endTimeNanos - startTimeNanos) / (10 ** 9).to_f
        total_duration += duration
        steps += valueArr[0]["intVal"]
      end
    end
    date = getDateOfSummary(startTime, startTimeNanos, oneDayNanos)
    saveSummary(steps, date, total_duration, false)
    puts 'save not final'
  end

   def newDayData(startTime, startTimeNanos, newStartTimeNanos, oneDayNanos)
      time1 = ((startTimeNanos - startTime) / oneDayNanos).to_i
      time2 = ((newStartTimeNanos - startTime) / oneDayNanos).to_i
      if time1 != time2
        return true
      else
        return false
      end
   end

   def getDateOfSummary(startTime, startTimeNanos, oneDayNanos)     #start of day
     i = ((startTimeNanos - startTime)/oneDayNanos).floor
     dateInNanos = startTime + (i *oneDayNanos)
     dateInSecs = (dateInNanos / (10 ** 9)).to_s
     return DateTime.strptime(dateInSecs,'%s')
   end

   def saveSummary(steps, date, total_duration, final)
     new_act =  Summary.new( user_id: current_user.id,
                             source: 'google',
                             group: 'walking',
                             total_duration: total_duration,
                             date: date,
                             steps: steps,
                             synced_at: DateTime.now(),
                             sync_final: final
     )
     new_act.save!
   end

   def get_last_synced_not_final_date(user_id, source)
     last_sync_date = DateTime.parse("2014-11-01 00:00:00").strftime('%s%9N')
     query = Summary.where("user_id= #{user_id} and source = '#{source}'")
     if  query.size() > 0
       last_sync = query.where("sync_final = 'f'").order(date: :desc).limit(1)[0]
       last_sync_date = last_sync.date
       last_sync_date = last_sync_date.strftime('%s%9N')
     end
     return last_sync_date
   end

  def query_steps
      start_time = get_last_synced_not_final_date(current_user.id,'google')
      end_time = DateTime.now().strftime('%s%9N')  #nanoseconds from epoch
      datasources = ("https://www.googleapis.com/fitness/v1/users/me/dataSources/derived:com.google.step_count.delta:com.google.android.gms:estimated_steps/datasets/"+start_time.to_s+"-"+end_time.to_s).strip
      #datasources = "https://www.googleapis.com/fitness/v1/users/me/dataSources/derived:com.google.step_count.delta:com.google.android.gms:estimated_steps/datasets/1252459233011941709-1422459233011941709".strip
      uri = URI.parse(URI.encode(datasources))
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri, {"Authorization" => "Bearer "+@access_token})
      return [http.request(request), start_time]
  end

  def refresh_token(google_conn)
    #post request to renew expired access token
    url = URI("https://accounts.google.com/o/oauth2/token")
    response = Net::HTTP.post_form(url, to_params())
    puts response
    data = JSON.parse(response.body)
    puts data
    new_access_token = data["access_token"]
    if new_access_token
      @access_token = data["access_token"]
      connection_data = JSON.parse(google_conn.data)
      connection_data["token"] = data["access_token"]
      google_conn.update(data: connection_data.to_json)
    end
  end

  def to_params
    {'refresh_token' => @refresh_token,
    'client_id' => CONNECTION_CONFIG["GOOGLE_CLIENT_ID"],
    'client_secret' => CONNECTION_CONFIG["GOOGLE_CLIENT_SECRET"],
    'grant_type' => 'refresh_token'}
  end

end


# https://www.googleapis.com/fitness/v1/users/{userId}/dataSources/{dataSourceId}/datasets/{datasetId} - dataset containing all data points  pl me - stepcounterid - fromto
# https://www.googleapis.com/fitness/v1/users/{userId}/dataSources/{dataSourceId} - datasource identified by datastream id
# https://www.googleapis.com/fitness/v1/users/{userId}/dataSources - list all datasources visible by developer,  pl stepcounter stb
# https://www.googleapis.com/fitness/v1/users/{userId}/sessions - list sessions previously created

module SyncGoogle
  def sync_google
    dateFormat = "%Y-%m-%d"
    google_conn = Connection.where(user_id: current_user.id, name: 'google').first
    if google_conn
      connection_data = JSON.parse(google_conn.data)
      puts 'connection data: '
      puts connection_data

      @user_id = 'me'
      @api_version = 'fitness/v1'
      @access_token = connection_data["token"] # only works if not expired
      @refresh_token = connection_data["refresh_token"]
      @host = 'www.googleapis.com'


      #post request to renew expired access token
      # url = URI("https://accounts.google.com/o/oauth2/token")
      # response = Net::HTTP.post_form(url, self.to_params)
      # puts response
      # data = JSON.parse(response.body)
      # puts data
      # @access_token = data["access_token"]
      #TODO data["expires_in"]


      uri = URI('https://www.googleapis.com/fitness/v1/users/me/dataSources')
      Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        request = Net::HTTP::Get.new uri.request_uri
        request['Authorization'] = @access_token
        response = http.request request
      end



      puts response





#      data2 = JSON.parse(response.body)

      result = { :status => "OK", :act => 'act'}
    else
      result = { :status => "ERR"}
    end
    respond_to do |format|
      format.json { render json: result}
    end
  end

  def to_params2
    {
        'access_token' => @access_token
    }
  end

  def to_params
    {'refresh_token' => @refresh_token,
    'client_id' => APP_CONFIG["GOOGLE_CLIENT_ID"],
    'client_secret' => APP_CONFIG["GOOGLE_CLIENT_SECRET"],
    'grant_type' => 'refresh_token'}
  end

  # def list_visible_datasources()
  #     puts 'list visible datasources'
  #     puts get("/users/#{@user_id}/datasources", {''})
  # end

  # def heart_rate_on_date(date)
  #     puts get("/users/#{@user_id}/datasources")
  # end

  private

  # def access_token
  #       @access_token ||= OAuth::AccessToken.new(consumer, @token, @secret)
  # end
  #
  # def refresh_token
  #    @refresh_token ||= OAuth::RequestToken.new("")
  # end
  #
  # def consumer
  #       @consumer ||= OAuth::Consumer.new(@consumer_key, @consumer_secret, {
  #         :site => 'https://api.fitbit.com',
  #         :proxy => @proxy
  #       })
  #     end

  # def get(path, headers={})
  #   extract_response_body raw_get(path, headers)
  # end
  #
  # def raw_get(path, headers={})
  #   #headers.merge!(Accept-Language' => @api_unit_system)
  #   uri = "/#{@api_version}#{path}"
  #   @access_token.get(uri, headers)
  # end
  #
  # def extract_response_body(resp)
  #   resp.nil? || resp.body.nil? ? {} : JSON.parse(resp.body)
  # end

end



# https://www.googleapis.com/fitness/v1/users/{userId}/dataSources/{dataSourceId}/datasets/{datasetId} - dataset containing all data points  pl me - stepcounterid - fromto
# https://www.googleapis.com/fitness/v1/users/{userId}/dataSources/{dataSourceId} - datasource identified by datastream id
# https://www.googleapis.com/fitness/v1/users/{userId}/dataSources - list all datasources visible by developer,  pl stepcounter stb
# https://www.googleapis.com/fitness/v1/users/{userId}/sessions - list sessions previously created
#
#
# https://www.googleapis.com/fitness/v1/users/me/dataSources
# https://www.googleapis.com/fitness/v1/users/me/dataSources/raw:com.google.step_count.cumulative:LGE:Nexus 5:d1bc969e:Step Counter
# https://www.googleapis.com/fitness/v1/users/me/dataSources/raw:com.google.step_count.cumulative:LGE:Nexus 5:d1bc969e:Step Counter/datasets/1252459233011941709-1422459233011941709
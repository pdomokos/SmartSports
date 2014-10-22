class PagesController < ApplicationController
  # skip_before_filter :require_login, only: [:index]
  require 'rubygems'
  require 'withings'

  Withings.consumer_key = ENV['WITHINGS_KEY']
  Withings.consumer_secret = ENV['WITHINGS_SECRET']

  @movesconn = nil
  @withingsconn = nil

  def index
  end

  def health

  end

  def movescb
    auth = request.env['omniauth.auth']
    if auth
      #TODO strore full auth_hash string in connection.data, not only moves access token
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'moves', data: auth['credentials']['token'], user_id: u.id)
      conn.save!
      redirect_to :controller => 'pages', :action => 'training'
    else
      #TODO please sign in first message
      redirect_to pages_settings_path
    end
  end

  def withingscb
    auth = request.env['omniauth.auth']
    if auth
      data = { "uid" => params[:userid],"acc_key" => auth['credentials']['token'],"acc_secret" => auth['credentials']['secret']}
      #TODO strore full auth_hash string in connection.data, not only withing uid,token,secret
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'withings', data: data, user_id: u.id)
      conn.save!
      redirect_to :controller => 'pages', :action => 'training'
    else
      #TODO please sign in first message
      redirect_to pages_settings_path
    end
  end


  def training
    @movesconn = Connection.where(user_id: current_user.id, name: 'moves').first
    @withingsconn = Connection.where(user_id: current_user.id, name: 'withings').first
    if @withingsconn
      @user =  Withings::User.authenticate(@withingsconn.data['uid'], @withingsconn.data['acc_key'], @withingsconn.data['acc_secret'])
    end
    if @movesconn
      @moves = Moves::Client.new(@movesconn.data)
    end
    respond_to do |format|
      format.html
      format.json
    end
    # render :text => "<pre>"+request.env["omniauth.auth"].to_yaml+"</pre>"
  end

  def mdestroy
    #TODO delete current_user connection where name = moves
    redirect_to pages_settings_path
  end

  def wdestroy
    #TODO delete current_user connection where name = withings
    redirect_to pages_settings_path
  end

  def lifestyle

  end

  def genetics

  end

  def settings
    @movesconn = Connection.where(user_id: current_user.id, name: 'moves').first
    @withingsconn = Connection.where(user_id: current_user.id, name: 'withings').first
  end

end

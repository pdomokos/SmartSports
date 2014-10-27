class PagesController < ApplicationController
  # skip_before_filter :require_login, only: [:index]
  require 'rubygems'
  require 'withings'

  @movesconn = nil
  @withingsconn = nil
  @fitbitconn = nil

  def index
  end

  def health

  end

  def movescb
    auth = request.env['omniauth.auth']
    if auth
      #TODO strore full auth_hash string in connection.data, not only moves access token
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'moves', data: auth['credentials']['token'].to_json, user_id: u.id)
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
      conn  = u.connections.create(name: 'withings', data: data.to_json, user_id: u.id)
      conn.save!
      redirect_to :controller => 'pages', :action => 'training'
    else
      #TODO please sign in first message
      redirect_to pages_settings_path
    end
  end

  def fitbitcb
    auth = request.env['omniauth.auth']
    if auth
      data = {"secret" => auth['credentials']['secret'],"token" => auth['credentials']['token']}
      #TODO strore full auth_hash string in connection.data, not only withing uid,token,secret
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'fitbit', data: data.to_json, user_id: u.id)
      conn.save!
      redirect_to :controller => 'pages', :action => 'training'
    else
      #TODO please sign in first message
      redirect_to pages_settings_path
    end
  end

  def training

    respond_to do |format|
      format.html
      format.json
    end
    # render :text => "<pre>"+request.env["omniauth.auth"].to_yaml+"</pre>"
  end

  def mdestroy
    moves_conn = Connection.where(user_id: current_user.id, name: 'moves').first
    if moves_conn
      moves_conn.destroy!
    end
    redirect_to pages_settings_path
  end

  def wdestroy
    withings_conn = Connection.where(user_id: current_user.id, name: 'withings').first
    if withings_conn
      withings_conn.destroy!
    end
    redirect_to pages_settings_path
  end

  def fdestroy
    fitbit_conn = Connection.where(user_id: current_user.id, name: 'fitbit').first
    if fitbit_conn
      fitbit_conn.destroy!
    end
    redirect_to pages_settings_path
  end

  def lifestyle

  end

  def genetics

  end

  def settings
    @movesconn = Connection.where(user_id: current_user.id, name: 'moves').first
    @withingsconn = Connection.where(user_id: current_user.id, name: 'withings').first
    @fitbitconn = Connection.where(user_id: current_user.id, name: 'fitbit').first
  end

end

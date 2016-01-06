
class ConnectionsController < ActionController::Base

  def failedcb
    logger.error("callback failed")
    logger.error(params)
  end


  def misfitcb
    auth = request.env['omniauth.auth']
    if auth
      u = User.find(current_user.id)
      data = auth['credentials']
      conn  = u.connections.create(name: 'misfit', data: data.to_json, user_id: u.id)
      conn.save!
    end
    redirect_to :controller => 'pages', :action => 'misfit', :locale => I18n.locale
  end

  def movescb
    auth = request.env['omniauth.auth']
    logger.debug("movescb called")
    logger.debug(JSON.pretty_generate(auth))
    if auth
      u = User.find(current_user.id)
      data = auth['credentials']
      conn  = u.connections.create(name: 'moves', data: data.to_json, user_id: u.id)
      conn.save!
    end
    redirect_to :controller => 'pages', :action => 'moves', :locale => I18n.locale
  end

  def withingscb
    auth = request.env['omniauth.auth']
    if auth
      data = auth['credentials']
      data.merge!({"uid" => params[:userid]})
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'withings', data: data.to_json, user_id: u.id)
      conn.save!
    end
    redirect_to :controller => 'pages', :action => 'withings', :locale => I18n.locale
  end

  def fitbitcb
    auth = request.env['omniauth.auth']
    if auth
      data = auth['credentials']
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'fitbit', data: data.to_json, user_id: u.id)
      conn.save!
    end
    redirect_to :controller => 'pages', :action => 'fitbit', :locale => I18n.locale
  end

  def googlecb
    auth = request.env['omniauth.auth']
    if auth
      data = auth['credentials']
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'google', data: data.to_json, user_id: u.id)
      conn.save!
    end
    redirect_to :controller => 'pages', :action => 'googlefit', :locale => I18n.locale
  end

end

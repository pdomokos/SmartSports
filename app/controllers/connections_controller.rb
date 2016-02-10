
class ConnectionsController < ActionController::Base

  def index
    if !owner?()
      send_error_json(params[:id], "Unauthorized", 403)
      return
    end

    @connections = current_user.connections.all
  end

  def destroy
    if !owner?()
      send_error_json(params[:id], "Unauthorized", 403)
      return
    end
    @conn = Connection.find_by_id(params[:id])
    if @conn.destroy
      send_success_json(@conn.id, { name: @conn.name})
    else
      send_error_json(@conn.id, "Delete failed", 400)
    end
  end

  def update
    logger.info("connection update called")
    if !owner?()
      send_error_json(params[:id], "Unauthorized", 403)
      return
    end
    @conn = current_user.connections.where(id: params[:id]).first
    if @conn.nil? || !params[:sync]
      send_error_json(params[:id], "Failed to sync", 400)
      return
    end
    @conn.sync_status = Connection.sync_statuses[:pending]
    @conn.save!
    Delayed::Job.enqueue SyncConnectionJob.new(@conn.name.to_sym, current_user.id, @conn.id)
    send_success_json(@conn.id, { name: @conn.name})
  end

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
    redirect_to :controller => 'pages', :action => 'connections', :locale => I18n.locale
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
    redirect_to :controller => 'pages', :action => 'connections', :locale => I18n.locale
  end

  def withingscb
    auth = request.env['omniauth.auth']
    if auth
      data = auth['credentials']
      data.merge!({"uid" => params[:userid]})
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'connections', data: data.to_json, user_id: u.id)
      conn.save!
    end
    redirect_to :controller => 'pages', :action => 'connections', :locale => I18n.locale
  end

  def fitbitcb
    auth = request.env['omniauth.auth']
    if auth
      data = auth['credentials']
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'fitbit', data: data.to_json, user_id: u.id)
      conn.save!
    end
    redirect_to :controller => 'pages', :action => 'connections', :locale => I18n.locale
  end

  def googlecb
    auth = request.env['omniauth.auth']
    if auth
      data = auth['credentials']
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'google', data: data.to_json, user_id: u.id)
      conn.save!
    end
    redirect_to :controller => 'pages', :action => 'connections', :locale => I18n.locale
  end

  private

  include AuthHelper
  include ResponseHelper
  include SaveClickRecord
end

class PagesController < ApplicationController
  before_action :set_user_data, only: [:dashboard, :health, :exercise, :diet, :explore, :settings]
  has_mobile_fu
  layout :which_layout

  @movesconn = nil
  @withingsconn = nil
  @fitbitconn = nil
  @googleconn = nil

  def which_layout
    is_mobile_device? || is_tablet_device? ? 'pages_mobile' : 'pages'
  end

  def formats=(values)
    # fall back to the browser view if the mobile or tablet version does not exist
    values << :html if values == [:mobile] or values == [:tablet]

    # DEBUG: force mobile. Uncomment if not debugging!
    #values = [:mobile, :html] if values == [:html]
    # values = [:tablet, :html] if values == [:html]

    super(values)
  end

  def dashboard
    @measurements = current_user.measurements.where(source: @default_source).order(date: :desc).limit(4)
  end

  def health
      @activity = Summary.new
      @measurement = Measurement.new
      @measurements = current_user.measurements.where(source: @default_source).order(created_at: :desc).limit(4)
  end

  def exercise
    @uid = current_user.id
    @conn = @shown_user.connections
    @activities = current_user.activities.where(source: @default_source).order(created_at: :desc).limit(4)
    # respond_to do |format|
    #   format.html
    #   format.json
    # end
    # render :text => "<pre>"+request.env["omniauth.auth"].to_yaml+"</pre>"
  end

  def explore
  end

  def diet
    @diets = current_user.diets.where(source: @default_source).order(created_at: :desc).limit(4)
  end

  def medication
    @insulin_types = MedicationType.where(:group => "insulin")
    @oral_medication_types = MedicationType.where(:group => "oral")
    @medications = current_user.medications.order(created_at: :desc).limit(4)
  end

  def wellbeing

  end

  def genetics

  end

  def analytics

  end

  def settings
    @movesconn = Connection.where(user_id: current_user.id, name: 'moves').first
    @withingsconn = Connection.where(user_id: current_user.id, name: 'withings').first
    @fitbitconn = Connection.where(user_id: current_user.id, name: 'fitbit').first
    @googleconn = Connection.where(user_id: current_user.id, name: 'google').first
    @misfitconn = Connection.where(user_id: current_user.id, name: 'misfit').first
  end

  def profile
    prf_json = current_user.as_json
    prf_json.delete("crypted_password")
    prf_json.delete("salt")
    prf_json.delete("reset_password_token")
    @prf = JSON.pretty_generate( prf_json )
  end
  def error
    # to display some error in case of app failure
  end

  def misfitcb
    auth = request.env['omniauth.auth']
    if auth
      u = User.find(current_user.id)
      data = auth['credentials']
      conn  = u.connections.create(name: 'misfit', data: data.to_json, user_id: u.id)
      conn.save!
      redirect_to :controller => 'pages', :action => 'settings'
    else
      #TODO please sign in first message
      redirect_to pages_settings_path
    end
  end

  def movescb
    auth = request.env['omniauth.auth']
    if auth
      u = User.find(current_user.id)
      data = auth['credentials']
      conn  = u.connections.create(name: 'moves', data: data.to_json, user_id: u.id)
      conn.save!
      redirect_to :controller => 'pages', :action => 'settings'
    else
      #TODO please sign in first message
      redirect_to pages_settings_path
    end
  end

  def withingscb
    auth = request.env['omniauth.auth']
    if auth
      data = auth['credentials']
      data.merge!({"uid" => params[:userid]})
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'withings', data: data.to_json, user_id: u.id)
      conn.save!
      redirect_to :controller => 'pages', :action => 'settings'
    else
      #TODO please sign in first message
      redirect_to pages_settings_path
    end
  end

  def fitbitcb
    auth = request.env['omniauth.auth']
    if auth
      data = auth['credentials']
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'fitbit', data: data.to_json, user_id: u.id)
      conn.save!
      redirect_to :controller => 'pages', :action => 'settings'
    else
      #TODO please sign in first message
      redirect_to pages_settings_path
    end
  end

  def googlecb
    auth = request.env['omniauth.auth']
    if auth
      data = auth['credentials']
      u = User.find(current_user.id)
      conn  = u.connections.create(name: 'google', data: data.to_json, user_id: u.id)
      conn.save!
      redirect_to :controller => 'pages', :action => 'settings'
    else
      #TODO please sign in first message
      redirect_to pages_settings_path
    end
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

  def gfdestroy
    fit_conn = Connection.where(user_id: current_user.id, name: 'google').first
    if fit_conn
      fit_conn.destroy!
    end
    redirect_to pages_settings_path
  end

  def friendship
    @friendship = Friendship.new
  end

private

  def get_shown_user(params)
    failed = false
    shown_user_id = params[:shown_user].to_i
    shown_user = nil
    if shown_user_id == current_user.id
      failed = true
    end

    if not failed and shown_user_id>0
      q = User.where("id = #{shown_user_id}")
      if q.size != 1
        failed = true
        logger.info "Invalid user id "+shown_user_id.to_s
      else
        shown_user = q.first()
      end
    end

    if not failed and shown_user
      if not shown_user.is_friend?(current_user.id)
        failed = true
        logger.info "Unauth user id "+shown_user_id.to_s
      end
    end

    if not shown_user
      shown_user = current_user
    end

    return shown_user
  end

  def set_user_data
    @shown_user = get_shown_user(params)
  end
end

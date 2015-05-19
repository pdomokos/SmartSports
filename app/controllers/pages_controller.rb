class PagesController < ApplicationController
  # before_action :set_user_data, only: [:dashboard, :health, :exercise, :diet, :explore, :settings, :mobilepage]
  before_action :redir_mobile, except: [:mobilepage]
  before_action :set_locale

  has_mobile_fu
  layout :which_layout

  @movesconn = nil
  @withingsconn = nil
  @fitbitconn = nil
  @googleconn = nil

  def which_layout
    is_mobile_device? || is_tablet_device? ? 'pages.mobile' : 'pages'
  end

  def redir_mobile
    if is_mobile_device? || is_tablet_device?
      redirect_to action: 'mobilepage'
    end
  end

  def formats=(values)
    # fall back to the browser view if the mobile or tablet version does not exist
    values << :html if values == [:mobile] or values == [:tablet]

    # DEBUG: force mobile. Uncomment if not debugging!
    #values = [:mobile, :html] if values == [:html]
    # values = [:tablet, :html] if values == [:html]

    super(values)
  end

  def mobilepage

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
    @conn = current_user.connections
    @activities = current_user.activities.where(source: @default_source).order(created_at: :desc).limit(4)
    # respond_to do |format|
    #   format.html
    #   format.json
    # end
    # render :text => "<pre>"+request.env["omniauth.auth"].to_yaml+"</pre>"
  end

  def explore
    user = nil
    if params[:user_id]
      user_id = params[:user_id].to_i
      user = User.where("id = #{user_id}").first
    end
    if user.nil?
      user = current_user
    end
    @sensor_measurements = user.sensor_measurements.order(start_time: :desc)
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
    @lifestyles = current_user.lifestyles.order(created_at: :desc).limit(4)
    @sleepList = Lifestyle.sleepList.join(";")
    @stressList = Lifestyle.stressList.join(";")
    @illnessList = Lifestyle.illnessList.join(";")
    @painList = Lifestyle.painList.join(";")
    @periodPainList = Lifestyle.periodPainList.join(";")
    @periodVolumeList = Lifestyle.periodVolumeList.join(";")
    @painTypeList = Lifestyle.painTypeList.join(";")
  end

  def genetics
    @relativeList = JSON.dump(FamilyHistory.relativeList)
    @diseaseList = JSON.dump(FamilyHistory.diseaseList)
    @family_histories = current_user.family_histories.order(created_at: :desc).limit(4)
  end

  def analytics

  end

  def settings
    prf_json = current_user.as_json
    prf_json.delete("crypted_password")
    prf_json.delete("salt")
    prf_json.delete("reset_password_token")
    @prf = JSON.pretty_generate( prf_json )
    @movesconn = Connection.where(user_id: current_user.id, name: 'moves').first
    if @movesconn
      @active_since_moves = @movesconn.created_at
      @last_sync_date_moves = get_last_synced_date(current_user.id, "moves")
    end
    @withingsconn = Connection.where(user_id: current_user.id, name: 'withings').first
    if @withingsconn
        @active_since_withings = @withingsconn.created_at
        @last_sync_date_withings = get_last_synced_date(current_user.id, "withings")
    end
    @fitbitconn = Connection.where(user_id: current_user.id, name: 'fitbit').first
    if @fitbitconn
      @active_since_fitbit = @fitbitconn.created_at
      @last_sync_date_fitbit = get_last_synced_date(current_user.id, "fitbit")
    end
    @googleconn = Connection.where(user_id: current_user.id, name: 'google').first
    if @googleconn
      @active_since_google = @googleconn.created_at
      @last_sync_date_google = get_last_synced_date(current_user.id, "google")
    end
    @misfitconn = Connection.where(user_id: current_user.id, name: 'misfit').first
    if @misfitconn
      @active_since_misfit = @misfitconn.created_at
      @last_sync_date_misfit = get_last_synced_date(current_user.id, "misfit")
    end
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

  # def set_user_data
  #   @shown_user = get_shown_user(params)
  # end
end

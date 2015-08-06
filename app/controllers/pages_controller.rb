class PagesController < ApplicationController
  include DashboardHelper

  # before_action :set_user_data, only: [:dashboard, :health, :exercise, :diet, :explore, :settings, :mobilepage]
  before_action :redir_mobile, except: [:mobilepage, :signin]
  before_action :set_locale
  before_action :set_user_data
  before_filter :require_login, except: [:signin, :signup, :reset_password]
  has_mobile_fu
  layout :which_layout

  @movesconn = nil
  @withingsconn = nil
  @fitbitconn = nil
  @googleconn = nil

  include SaveClickRecord

  # login/register, resetpw
  def reset_password
    @values = JSON.dump(I18n.t :popupmessages)
  end

  def signup
    @values = JSON.dump(I18n.t :popupmessages)
  end

  def signin
    # browser_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    # puts "browser locale: #{browser_locale}"
    # I18n.locale = browser_locale || I18n.default_locale
    @user = User.new
    @values = JSON.dump(I18n.t :popupmessages)

    @lang_label = 'hu'
    if I18n.locale.to_s=='hu'
      @lang_label = 'en'
    end
  end

  def mobilepage
    @counts = []
    @counts[0] = Diet.where(user_id: current_user.id).count
    @counts[1] = Activity.where(user_id: current_user.id).count
    @counts[2] = Measurement.where(user_id: current_user.id).count
    @counts[3] = Medication.where(user_id: current_user.id).count
    @counts[4] = Lifestyle.where(user_id: current_user.id).count
    @counts[5] = FamilyHistory.where(user_id: current_user.id).count
    @counts[6] = LabResult.where(user_id: current_user.id).count
    @relativeList = JSON.dump(FamilyHistory.relativeList)
    @diseaseList = JSON.dump(FamilyHistory.diseaseList)
  end

  def dashboard
    @measurements = current_user.measurements.where(source: @default_source).order(date: :desc).limit(4)

    get_todays_summary()

    # u.summaries.where(group: 'walking').where("date between ? and ?", DateTime.now.at_beginning_of_month, DateTime.now)

    save_click_record(:success, nil, nil)
  end

  def health
      @activity = Summary.new
      @measurement = Measurement.new
      @measurements = current_user.measurements.where(:source => [@default_source, 'demo']).order(created_at: :desc).limit(4)
      @values = JSON.dump(I18n.t :popupmessages)
      save_click_record(:success, nil, nil)
  end

  def exercise
    @uid = current_user.id
    @conn = current_user.connections
    @activities = current_user.activities.where(source: @default_source).order(created_at: :desc).limit(4)
    @intensity_values = Activity.intensity_values
    @values = JSON.dump(I18n.t :popupmessages)
    save_click_record(:success, nil, nil)
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
    @values = JSON.dump(I18n.t :popupmessages)
    save_click_record(:success, nil, nil)
  end

  def diet
    @diets = current_user.diets.where(source: @default_source).order(created_at: :desc).limit(4)
    @values = JSON.dump(I18n.t :popupmessages)
    save_click_record(:success, nil, nil)
  end

  def medication
    @insulin_types = MedicationType.where(:group => "insulin")
    @oral_medication_types = MedicationType.where(:group => "oral")
    @medications = current_user.medications.order(created_at: :desc).limit(4)
    @values = JSON.dump(I18n.t :popupmessages)
    save_click_record(:success, nil, nil)
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
    @values = JSON.dump(I18n.t :popupmessages)
    save_click_record(:success, nil, nil)
  end

  def genetics
    @relativeList = JSON.dump(FamilyHistory.relativeList)
    @diseaseList = JSON.dump(FamilyHistory.diseaseList)
    @family_histories = current_user.family_histories.order(created_at: :desc).limit(4)
    @values = JSON.dump(I18n.t :popupmessages)
    save_click_record(:success, nil, nil)
  end

  def labresult
    @values = JSON.dump(I18n.t :popupmessages)
    save_click_record(:success, nil, nil)
  end

  def analytics
    save_click_record(:success, nil, nil)
    if params[:user_id] && current_user.admin?
      @selected_user = User.find_by_id(params[:user_id])
    end
  end

  def settings
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
    @user = current_user
    if @user.profile.nil?
      @user.profile = Profile.create()
    end
    @profile = @user.profile
    @values = JSON.dump(I18n.t :popupmessages)
    if current_user.admin
      @users = User.all
      @profiles = Profile.all
      @visits = get_visits("all")
      @clickrecords = ClickRecord.where(msg: 'login_succ').order(created_at: :desc).group('user_id')
    end
    save_click_record(:success, nil, nil)
  end

  def get_visits(uid)
    # uid = params[:uid]
    if uid
      startTime=DateTime.now-1.week
      if uid == "all"
        crs = ClickRecord.where("created_at >= :start_date", {start_date: startTime})
      else
        crs = ClickRecord.where("user_id = :user_id AND created_at >= :start_date", {user_id: uid, start_date: startTime})
      end
    end
    visits = Array.new(168)
    first = startTime
    (0..167).each do |i|
      visits[i] = [i+1, first,0]
      first = first+1.hour
    end

    arr = crs.group_by{ |u|
      u.created_at.beginning_of_hour
    }

    arr = arr.collect{ |it| [(it[0].strftime("%s").to_i-startTime.strftime("%s").to_i)/60/60, it[0],it[1].length]}
    puts arr


    arr.each{ |it| visits[it[0]-2][2] = it[2]}

    @visits = visits.to_json

  end

  def analytics2

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
      redirect_to :controller => 'pages', :action => 'settings', :locale => I18n.locale
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
      redirect_to :controller => 'pages', :action => 'settings', :locale => I18n.locale
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
      redirect_to :controller => 'pages', :action => 'settings', :locale => I18n.locale
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
      redirect_to :controller => 'pages', :action => 'settings', :locale => I18n.locale
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
      redirect_to :controller => 'pages', :action => 'settings', :locale => I18n.locale
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

  def which_layout
    if is_mobile_device?
      if action_name=='signin' || action_name=='signup' || action_name=='reset_password'
        'auth.mobile'
      else
        'pages.mobile'
      end
    elsif action_name=='signin' || action_name=='signup' || action_name=='reset_password'
      'auth'
    else
      'pages'
    end
  end

  def redir_mobile
    if is_mobile_device?
      redirect_to url_for( :action => 'mobilepage', :locale => I18n.locale)
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
    @display_name = ""
    if current_user
      @display_name = current_user.name
      prf = current_user.profile
      if (!prf.nil?) && (!prf.firstname.nil? || !prf.lastname.nil?) && (prf.firstname!='' || prf.lastname!='')
        @display_name = prf.firstname+' '+prf.lastname
        if I18n.locale && I18n.locale.to_s=='hu'
          @display_name = prf.lastname+' '+prf.firstname
        end
      end
    end
  end

end

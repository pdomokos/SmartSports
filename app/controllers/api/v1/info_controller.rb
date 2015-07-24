module Api::V1
  class InfoController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!
    respond_to :json

    def index
      user_id = params[:user_id]
      user = User.find(user_id)

      movesconn = Connection.where(user_id: user.id, name: 'moves').first
      if movesconn
        active_since_moves = movesconn.created_at
        last_sync_date_moves = get_last_synced_date(user.id, "moves")
      end
      withingsconn = Connection.where(user_id: user.id, name: 'withings').first
      if withingsconn
        active_since_withings = withingsconn.created_at
        last_sync_date_withings = get_last_synced_date(user.id, "withings")
      end
      fitbitconn = Connection.where(user_id: user.id, name: 'fitbit').first
      if fitbitconn
        active_since_fitbit = fitbitconn.created_at
        last_sync_date_fitbit = get_last_synced_date(user.id, "fitbit")
      end
      googleconn = Connection.where(user_id: user.id, name: 'google').first
      if googleconn
        active_since_google = googleconn.created_at
        last_sync_date_google = get_last_synced_date(user.id, "google")
      end
      misfitconn = Connection.where(user_id: user.id, name: 'misfit').first
      if misfitconn
        active_since_misfit = misfitconn.created_at
        last_sync_date_misfit = get_last_synced_date(user.id, "misfit")
      end

      if user.profile.nil?
        user.profile = Profile.create()
      end
      profile = user.profile
      if user.admin
        users = User.all
        profiles = Profile.all
        clickrecords = ClickRecord.where(msg: 'login_succ').order(created_at: :desc).group('user_id')
      end
      save_click_record(:success, nil, nil)
      render json: {:profile => profile, :movesconn => movesconn, :withingsconn => withingsconn, :fitbitconn => fitbitconn, :googleconn => googleconn, :misfitconn => misfitconn}
    end

    def get_last_synced_date(user_id, source)
      last_sync_date = nil
      last_sync = Summary.where(user_id: user_id).where(source: source).order(synced_at: :desc).limit(1)[0]
      if  last_sync
        last_sync_date = last_sync.synced_at
      end
      return last_sync_date
    end

  end
end
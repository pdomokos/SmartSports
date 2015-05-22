class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :require_login
  before_filter :set_default_variables

  include SaveClickRecord

  private

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
    else
      browser_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
      puts "browser locale: #{browser_locale}"
      I18n.locale = browser_locale || I18n.default_locale
    end
    puts "set locale: #{I18n.locale}"
  end

  # def default_url_options(options={})
  #   { :locale => I18n.locale }
  # end

  def not_authenticated
     redirect_to login_path, alert: "Please login first"
  end

  def set_default_variables
    @default_source = "smartdiab"

    @meas_map = {
        'blood_sugar' => 'bloodglucose',
        'weight' => 'weight40',
        'waist' => 'abdominal40',
        'blood_pressure' => 'bloodpressure40'
    }
  end

  def get_last_synced_date(user_id, source)
    last_sync_date = nil
    last_sync = Summary.where(user_id: user_id).where(source: source).order(synced_at: :desc).limit(1)[0]
    if  last_sync
      last_sync_date = last_sync.synced_at
    end
    return last_sync_date
  end

  def send_success_json(id, data={})
    save_click_record( :success, id )
    resp = data.merge({id: id, ok: true})
    render json: resp
  end

  def send_error_json(id, msg, status)
    save_click_record( :failure, id, msg )
    render json: { msg:  msg, ok: false }, :status => status
  end
end

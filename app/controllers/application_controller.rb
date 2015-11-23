class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :require_login
  before_filter :set_default_variables

  include SaveClickRecord
  include ResponseHelper

  private

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
    else
      browser_lang = request.env['HTTP_ACCEPT_LANGUAGE']
      if !browser_lang.nil?
        browser_locale = browser_lang.scan(/^[a-z]{2}/).first
        I18n.locale = browser_locale || I18n.default_locale
      end
    end

    @lang_label = 'hu'
    if I18n.locale.to_s=='hu'
      @lang_label = 'en'
    end
  end

  # def default_url_options(options={})
  #   { :locale => I18n.locale }
  # end

  def not_authenticated
     redirect_to "/#{I18n.locale}/pages/signin", alert: "Please login first"
  end

  def set_default_variables
    lang = params[:lang]
    if lang
      I18n.locale=lang
    end

    @default_source = "smartdiab"

    @meas_map = {
        'blood_sugar' => 'bloodglucose',
        'weight' => 'weight40',
        'waist' => 'abdominal40',
        'blood_pressure' => 'bloodpressure40'
    }

    @hidden_forms = false
  end

  def get_last_synced_date(user_id, source)
    last_sync_date = nil
    last_sync = Summary.where(user_id: user_id).where(source: source).order(synced_at: :desc).limit(1)[0]
    if  last_sync
      last_sync_date = last_sync.synced_at
    end
    return last_sync_date
  end

#
  def check_auth()
    if !owner?() && !doctor?()
      send_error_json(params[:id], "Unauthorized", 403)
      return false
    end
    return true
  end

  def check_doctor()
    if self.try(:current_user).try(:doctor?)
      return true
    end
    return false
  end
  alias_method :doctor?, :check_doctor

  def check_admin()
    if self.try(:current_user).try(:admin?)
      return true
    end
    return false
  end
  alias_method :admin?, :check_admin

  def check_owner()
    user_id = params[:user_id].to_i
    if self.try(:current_user).try(:id) == user_id
      return true
    end
    return false
  end
  alias_method :owner?, :check_owner

end


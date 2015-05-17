class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :require_login
  before_filter :set_default_variables
  before_action :set_locale

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

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
end

class ErrorsController < ApplicationController
  before_action :set_locale

  def general
  end

  def unauthorized

  end

  private

  def set_locale
    if params[:locale]
      I18n.locale = params[:locale]
    else
      browser_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
      I18n.locale = browser_locale || I18n.default_locale
    end
  end
end

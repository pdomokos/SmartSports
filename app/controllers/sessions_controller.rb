class SessionsController < ApplicationController
  has_mobile_fu
  layout :which_layout
  skip_before_filter :require_login, except: [:destroy]

  def which_layout
    is_mobile_device? || is_tablet_device? ? 'auth.mobile' : 'auth'
  end

  def formats=(values)
    # fall back to the browser view if the mobile or tablet version does not exist
    values << :html if values == [:mobile] or values == [:tablet]

    # DEBUG: force mobile. Uncomment if not debugging!
    #values = [:mobile, :html] if values == [:html]
    # values = [:tablet, :html] if values == [:html]

    super(values)
  end

  def reset_password
  end

  def signup
  end

  def signin
    browser_locale = request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
    puts "browser locale: #{browser_locale}"
    I18n.locale = browser_locale || I18n.default_locale
    @user = User.new
  end

  def create
    if @user = login(params[:email], params[:password])

      redirect_back_or_to('/hu/pages/diet', {notice: 'Login successful'})
    else
      flash.now[:alert] = 'Login failed'
      redirect_to('/login', {notice: 'Login failed!'})
    end
  end

  def destroy
    logout
    redirect_to('/login', { notice: 'Logged out!'})
  end
end

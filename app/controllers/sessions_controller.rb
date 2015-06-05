class SessionsController < ApplicationController
  respond_to :json
  skip_before_filter :require_login, except: [:destroy]

  def create
    @user = login(params[:email], params[:password])
    if @user
        save_click_record(:success, -1, "login_succ")
        render json: { :ok => true, :msg => 'login_succ', :locale => I18n.locale, :profile => @user.has_profile}
    else
      save_click_record(:failure, -1, "login")
      render json: { :ok => false, :msg => 'login_failed'}, status: 403
    end
  end

  def signout
    save_click_record(:success, -1, "logout")
    logout
    render json: { :ok => true, :msg => 'logout_succ'}
  end
end

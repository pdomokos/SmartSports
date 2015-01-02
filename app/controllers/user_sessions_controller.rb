class UserSessionsController < ApplicationController
  skip_before_filter :require_login, except: [:destroy]

  def create
    if @user = login(params[:email], params[:password])
      redirect_back_or_to({controller: 'pages', action: 'dashboard'}, {notice: 'Login successful'})
    else
      flash.now[:alert] = 'Login failed'
      redirect_to(pages_login_path, {notice: 'Login failed!'})
    end
  end

  def destroy
    logout
    redirect_to({controller: 'pages', action: 'dashboard'}, {notice: 'Logged out!'})
  end
end

class SessionsController < ApplicationController
  layout 'auth'
  skip_before_filter :require_login, except: [:destroy]

  def reset_password
  end

  def signin
    @user = User.new
  end

  def create
    if @user = login(params[:email], params[:password])

      redirect_back_or_to({controller: 'pages', action: 'dashboard'}, {notice: 'Login successful'})
    else
      puts "login failed"
      flash.now[:alert] = 'Login failed'
      redirect_to('/login', {notice: 'Login failed!'})
    end
  end

  def destroy
    logout
    redirect_to('/login', { notice: 'Logged out!'})
  end
end

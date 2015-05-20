class SessionsController < ApplicationController
  respond_to :json
  skip_before_filter :require_login, except: [:destroy]

  def create
    if @user = login(params[:email], params[:password])
      render json: { :ok => true, :msg => 'login_succ'}
    else
      render json: { :ok => false, :msg => 'login_failed'}, status: 403
    end
  end

  def signout
    logout
    render json: { :ok => true, :msg => 'logout_succ'}
  end
end

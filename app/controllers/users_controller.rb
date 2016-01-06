class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  skip_before_filter :require_login, only: [:new, :create]

  include UsersCommon

  # GET /users
  # GET /users.json
  def index
    if !current_user.admin
      respond_to do |format|
        format.html { redirect_to errors_unauthorized_path }
        format.json { render json: { :status => 'NOK', :msg => 'error_unauthorized' }, status: 403  }
      end
      return
    end
    @users = User.all
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    @user.username = @user.email.split("@")[0]
    @user.name = @user.username
    respond_to do |format|
      if @user.save
        UserMailer.delay.user_created_email(@user)

        @user = login(user_params['email'], user_params['password'])

        if @user
          save_click_record(:success, nil, "login", request.remote_ip)
          format.json { render json: {:ok => true, status: 'OK', :msg => 'login_succ', :id => @user.id, :locale => I18n.locale, :profile => @user.has_profile} }
        else
          format.json { render json: {:ok => false, status: 'NOK', :msg => 'login_err'} }
        end

      else
        key = @user.errors.values[0]
        message = (I18n.translate(key))
        format.json { render json: {ok: false, status: 'NOK', msg: message}, status: 401 }
      end
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    if !current_user.admin? && !current_user.doctor? && current_user.id != @user.id
      respond_to do |format|
        format.html { redirect_to errors_unauthorized_path }
        format.json { render json: { :status => 'NOK', :msg => 'error_unauthorized' }, status: 403  }
      end
      return
    end

  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  def upload
    # par = params.require(:user).permit( :name, :avatar)
    user = User.find(params[:user_id])
    user.avatar = params[:avatar]
    user.save!
    respond_to do |format|
      format.html { redirect_to '/pages/mobilepage#settingsPage' }
    end
  end

  def uploadAv
    user = User.find(params[:user_id])
    user.avatar = params[:avatar]
    if user.save
      redirect_to pages_profile_path({:locale => I18n.locale})
    end
  end

end

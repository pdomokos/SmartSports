class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  skip_before_filter :require_login, only: [:new, :create]

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

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
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
        format.json { render json: {:ok => true, :id => @user.id} }
      else
        puts @user.errors.full_messages.to_sentence
        format.json { render json: { ok: false, msg: @user.errors.full_messages.to_sentence}, status: 401 }
      end
    end
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

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
     respond_to do |format|
      par = params.require(:user).permit( :password, :password_confirmation, :name)
      if @user.update(par)
        format.json { render json: { ok: true, msg: "Updated successfully" } }
      else
        format.json { render json: { ok: true, msg: "Update errror" } }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if !current_user.admin || current_user.id==@user.id
      respond_to do |format|
        format.html { redirect_to errors_unauthorized_path }
        format.json { render json: { :ok => false, :msg => 'error_unauthorized' }, status: 403  }
      end
      return
    end

    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { render json: { :ok => true }}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit( :email, :password, :password_confirmation, :name, :avatar)
    end
end

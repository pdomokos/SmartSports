class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  skip_before_filter :require_login, only: [:new, :create]

  # GET /users
  # GET /users.json
  def index
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
        demo_user = User.where( :email => "balint.domokos@larkbio.com").first
        if demo_user
          friendship = Friendship.new({:user1_id => @user.id, :user2_id => demo_user.id, :authorized => true})
          friendship.save
        end
        UserMailer.delay.user_created_email(@user)

        format.html { redirect_to user_path(@user), notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      par = params.require(:user).permit( :password, :password_confirmation, :name)
      if @user.update(par)
        format.html { redirect_to user_path(@user), notice: 'User was successfully updated.' }
        format.json { render json: { :status => "OK", :msg => "Updated successfully" } }
      else
        format.html { redirect_to users_path, notice: 'Create user failed.' }
        format.json { render json: { :status => "NOK", :msg => "Update errror" } }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit( :email, :password, :password_confirmation, :name)
    end
end

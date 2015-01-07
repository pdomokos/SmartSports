class NotificationsController < ApplicationController
  before_action :set_notification, only: [:show, :edit, :update, :destroy]

  # GET /notifications
  # GET /notifications.json
  def index
    user_id = params[:user_id]
    @user = User.find(user_id)
    @notifications = Notification.where("user_id = #{user_id}").order(date: :desc)
  end

  # GET /notifications/1
  # GET /notifications/1.json
  def show

  end

  # GET /notifications/new
  def new
    user_id = params[:user_id]
    @user = User.find(user_id)
    @notification = @user.notifications.create
  end

  # GET /notifications/1/edit
  def edit
  end

  # POST /notifications
  # POST /notifications.json
  def create
    user_id = params[:user_id]
    @user = User.find(user_id)
    @notification = @user.notifications.create(notification_params)

    respond_to do |format|
      if @notification.save
        format.html { redirect_to @notification, notice: 'Notification was successfully created.' }
        format.json { render :show, status: :created, location: @notification }
      else
        format.html { render :new }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    respond_to do |format|
      if @notification.update(notification_params)
        format.html { redirect_to @notification, notice: 'Notification was successfully updated.' }
        format.json { render :show, status: :ok, location: @notification }
      else
        format.html { render :edit }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /notifications/1
  # DELETE /notifications/1.json
  def destroy
    user = @notification.user
    @notification.destroy
    respond_to do |format|
      format.html { redirect_to user_notifications_url(user), notice: 'Notification was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_notification
      @notification = Notification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def notification_params
      params.require(:notification).permit( :title, :detail, :notification_type, :notification_data, :date)
    end
end
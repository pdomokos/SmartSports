module NotificationsCommon
  require 'json'
  def create
    @user = User.find(params[:user_id])
    par = notification_params
    if par[:notification_type]
      par[:notification_type] = par[:notification_type].to_sym
    end
    @notification = @user.notifications.new(par)

    if @notification.date < Time.zone.now-5.minutes
      send_error_json(@notification.id, "Notif time in the past", 400)
      return
    end

    respond_to do |format|
      if @notification.save
        @notification.send_push()
        # format.html { redirect_to @notification, notice: 'Notification was successfully created.' }
        format.json { send_success_json(@notification.id, {msg: "created" } ) }
      else
        # format.html { render :new }
        format.json { render json: @notification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /notifications/1
  # PATCH/PUT /notifications/1.json
  def update
    if params[:dismiss]
      @notification.dismissed_on = Time.zone.now
      if @notification.save
        send_success_json(@notification.id, {:msg => "dismissed"})
      else
        send_error_json(@notification.id, "dismiss_error", 400)
      end
      return
    end
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
    if @notification.destroy
      send_success_json(@notification.id, {:msg => "deleted"})
    else
      send_error_json(@notification.id, "delete_error", 400)
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_notification
    @notification = Notification.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def notification_params
    params.require(:notification).permit( :title, :detail, :notification_type, :notification_data, :date, :remind_at, :location, :location_url, :created_by, :recurrence_data, :default_data, :form_name)
  end



end

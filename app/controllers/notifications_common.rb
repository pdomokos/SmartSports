module NotificationsCommon
  def create
    user_id = params[:user_id]
    @user = User.find(user_id)
    par = notification_params
    if par[:notification_type]
      par[:notification_type] = par[:notification_type].to_sym
    end
    @notification = @user.notifications.new(par)

    respond_to do |format|
      if @notification.save
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
    @notification = Notification.find_by_id( params[:id].to_i)
    if @notification.nil?
      send_error_json(nil, "not_found", 400)
      return
    end

    if !check_owner()
      send_error_json(@notification.id, "Unauthorized", 403)
      return
    end

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
    params.require(:notification).permit( :title, :detail, :notification_type, :notification_data, :date, :remind_at, :location, :location_url, :created_by, :custom_form_id)
  end

  def check_owner()
    if self.try(:current_user).try(:id) == @notification.user_id
      return true
    end
    if self.try(:current_resource_owner).try(:id) == @notification.user_id
      return true
    end
    return false
  end
end
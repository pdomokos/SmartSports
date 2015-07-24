module UsersCommon

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    lang = params[:usermodlang]
    if lang
      I18n.locale=lang
      puts lang
    end
    respond_to do |format|
      par = params.require(:user).permit(:password, :password_confirmation, :name)
      if @user.update(par)
        puts "update succ"
        format.json { render json: {ok: true, status: 'OK', msg: "Updated successfully"} }
      else
        puts "update err"
        key = @user.errors.values[0]
        message = (I18n.translate(key))
        format.json { render json: {ok: false, status: 'NOK', msg: message} }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    if !current_user.admin || current_user.id==@user.id
      respond_to do |format|
        # format.html { redirect_to errors_unauthorized_path }
        format.json { render json: {:ok => false, :status => 'NOK', :msg => 'error_unauthorized'}, status: 403 }
      end
      return
    end

    @user.destroy
    respond_to do |format|
      # format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { render json: {:ok => true, :status => 'OK'} }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name, :avatar)
  end
end



module PasswordResetsCommon

  def create
      @user = User.find_by_email(params[:email])
      begin
        if @user
          logger.info "delivering password reset instructions to "+params[:email]
          @user.deliver_reset_password_instructions!
          render json: {:ok => true, :locale => I18n.locale}
        else
          render json: {:ok => false, :locale => I18n.locale}
        end
      rescue => e
        logger.info "Exception"
        logger.error e
        logger.error e.backtrace.join("\n")
        #redirect_to(root_path, :notice => 'Failed to send email.')
        render json: {:ok => false, :locale => I18n.locale}
      end
  end

end
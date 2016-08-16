module Api::V1
  class PasswordResetsController < ApiController
    before_action :doorkeeper_authorize!, except: 'create'

    require 'json'

    def create
      @user = User.find_by_email(params[:email])
      begin
        if @user
          logger.info "delivering password reset code to #{params[:email]}, locale: #{params[:lang]}"
          if params[:lang]
            @user.mail_lang = params[:lang]
          end
          code=SecureRandom.urlsafe_base64[0..5]
          @user.reset_password_code = code
          @user.save!
          Delayed::Job.enqueue InfoMailJob.new(:reset_password_email_api, @user.email, I18n.locale, {reset_code: code, api_call: true})

          render json: {:ok => true, :locale => I18n.locale}
        else
          render json: {:ok => false, :locale => I18n.locale}
        end
      rescue => e
        logger.info "Exception"
        logger.error e
        logger.error e.backtrace.join("\n")
        render json: {:ok => false, :locale => I18n.locale}
      end
    end

  end
end
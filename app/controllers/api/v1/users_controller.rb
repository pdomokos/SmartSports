module Api::V1
  class UsersController < ApiController
    before_action :doorkeeper_authorize!, except: [:create, :reset]

    # POST /users
    # POST /users.json
    def create
      @user = User.new(user_params)

      @user.username = @user.email.split("@")[0]
      @user.name = @user.username
      if user_params[:device]
        @user.device = user_params[:device]
      else
        @user.device = 10
      end
      respond_to do |format|
        if @user.save
          @user.profile = Profile.new(profile_params)
          @user.profile.save!
          mail_lang = profile_params[:default_lang]
          if mail_lang != 'hu' && mail_lang != 'en'
            mail_lang = 'en'
          end
          Delayed::Job.enqueue InfoMailJob.new(:user_created_email_api, @user.email, mail_lang, {})

          save_click_record(:success, nil, "login", request.remote_ip)
          format.json { render json: {:ok => true, :msg => 'reg_succ', :id => @user.id, :locale => I18n.locale, :profile => @user.has_profile} }
        else
          keys = @user.errors.full_messages().collect{|it| it.split()[-1]}
          # message = (I18n.translate(key))
          format.json { render json: {ok: false, msg: keys} }
        end
      end
    end

    def reset
      @user = User.find_by_email(params[:user][:email])
      begin
        if @user
          if(@user.reset_password_code && !@user.reset_password_code.empty? && @user.reset_password_code.to_s == params[:user][:reset_password_code].to_s)
            if (user_params[:password] && !user_params[:password].empty?) || (user_params[:password_confirmation] && !user_params[:password_confirmation].empty?)
              par = params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_code)
              par[:reset_password_code] = ""
              if @user.update(par)
                render json: { :ok => true, :msg => "reset_password_success", :pw_msg =>[]}
              else
                pw_keys = @user.errors.full_messages().collect{|it| it.split()[-1]}
                render json: { :ok => false, :msg => "reset_password_error1", :pw_msg =>pw_keys}
              end
            else
              render json: { :ok => false, :msg => "reset_password_error2", :pw_msg =>[]}
            end
          else
            render json: { :ok => false, :msg => "reset_password_error3", :pw_msg =>[]}
          end
        else
          render json: { :ok => false, :msg => "reset_password_error4", :pw_msg =>[]}
        end
      rescue => e
        logger.info "Exception"
        logger.error e
        logger.error e.backtrace.join("\n")
        render json: { :ok => false, :msg => "reset_password_error5", :pw_msg =>[]}
      end
    end

    def update
      @user = User.find(params[:id])
      if request.patch?
        # To update custom form order

        o = params[:custom_form_order]
        if !o
          send_error_json(@user.id, "order missing", 400)
          return
        end
        arr = o.split(',')
        n = @user.custom_forms.size
        if n!=arr.size
          send_error_json(@user.id, "order wrong_length", 400)
          return
        end
        User.transaction do
          i = 0
          for c in @user.custom_forms.order(:id) do
            c.order_index = arr[i]
            i += 1
            c.save
          end
        end
        send_success_json(@user.id, {:msg => "order updated"})
      elsif request.put?
          par = params.require(:user).permit(:dev_token)
          if @user.update(par)
            send_success_json_norecord(@user.id, {:msg => "token updated"})
          else
            send_error_json_norecord(@user.id, "failed to update token", 400)
            logger.warn("token update failed, #{params}")
          end
      else
        send_error_json(nil, "method unknown", 400)
      end

    end

    private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name, :avatar, :device)

    end

    def profile_params
      params.require(:profile).permit(:firstname, :lastname, :blood_glucose_min, :blood_glucose_max, :blood_glucose_unit, :morning_start, :noon_start, :evening_start, :night_start, :default_lang)
    end

  end
end

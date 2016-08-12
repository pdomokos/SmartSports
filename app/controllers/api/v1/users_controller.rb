module Api::V1
  class UsersController < ApiController
    before_action :doorkeeper_authorize!, except: 'create'

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
          @user.profile = Profile.new
          @user.profile.firstname = profile_params[:firstname]
          @user.profile.lastname = profile_params[:lastname]
          @user.profile.default_lang = profile_params[:default_lang]
          @user.profile.save!
          mail_lang = profile_params[:default_lang]
          if mail_lang != 'hu' && mail_lang != 'en'
            mail_lang = 'en'
          end
          Delayed::Job.enqueue InfoMailJob.new(:user_created_email, @user.email, mail_lang, {})

          save_click_record(:success, nil, "login", request.remote_ip)
          format.json { render json: {:ok => true, :msg => 'reg_succ', :id => @user.id, :locale => I18n.locale, :profile => @user.has_profile} }
        else
          keys = @user.errors.full_messages().collect{|it| it.split()[-1]}
          # message = (I18n.translate(key))
          format.json { render json: {ok: false, msg: keys} }
        end
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
      params.require(:profile).permit(:firstname, :lastname, :default_lang)
    end

  end
end

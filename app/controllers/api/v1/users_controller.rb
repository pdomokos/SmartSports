module Api::V1
  class UsersController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!, only: [:update, :destroy]
    respond_to :json

    include UsersCommon

    # POST /users
    # POST /users.json
    def create
      @user = User.new(user_params)

      lang = params[:reglang]

      if lang
        I18n.locale=lang
        puts lang
      end
      @user.username = @user.email.split("@")[0]
      @user.name = @user.username
      respond_to do |format|
        if @user.save
          UserMailer.delay.user_created_email(@user)

          lang = params[:reglang]
          if lang
            I18n.locale=lang
            puts lang
          end
          if @user
            save_click_record(:success, nil, "login", request.remote_ip)
            format.json { render json: {:ok => true, status: 'OK', :msg => 'reg_succ', :id => @user.id, :locale => I18n.locale, :profile => @user.has_profile} }
          else
            format.json { render json: {:ok => false, status: 'NOK', :msg => 'reg_err'} }
          end

        else
          key = @user.errors.values[0]
          message = (I18n.translate(key))
          puts @user.errors.full_messages
          format.json { render json: {ok: false, status: 'NOK', msg: message}, status: 401 }
        end
      end
    end

  end
end

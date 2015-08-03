module Api::V1
  class UsersController < ApiController
    before_action :doorkeeper_authorize!, except: 'create'

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
          @user.profile = Profile.create()
          @user.save!
          UserMailer.delay.user_created_email(@user)
          lang = params[:reglang]
          if lang
            I18n.locale=lang
            puts lang
          end
          save_click_record(:success, nil, "login", request.remote_ip)
          format.json { render json: {:ok => true, :msg => 'reg_succ', :id => @user.id, :locale => I18n.locale, :profile => @user.has_profile} }
        else
          keys = @user.errors.full_messages().collect{|it| it.split()[-1]}
          # message = (I18n.translate(key))
          format.json { render json: {ok: false, msg: keys} }
        end
      end
    end

    private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name, :avatar)
    end

  end
end

module Api::V1
  class UsersController < ApiController
    before_action :doorkeeper_authorize!, except: 'create'

    # POST /users
    # POST /users.json
    def create
      @user = User.new(user_params)

      @user.username = @user.email.split("@")[0]
      @user.name = @user.username
      respond_to do |format|
        if @user.save
          @user.profile = Profile.create()
          @user.save!
          UserMailer.delay.user_created_email(@user)

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
      else
        send_error_json(nil, "method unknown", 400)
      end

    end
    private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name, :avatar)
    end

  end
end

class CustomFormsController < ApplicationController
  def index
    @user_id = params[:user_id].to_i
    user = User.find(@user_id)
    if !check_owner()
      send_error_json(@user_id, "Unauthorized", 403)
    end
    @custom_forms = user.custom_forms
  end

  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    @custom_form = user.custom_forms.build(custom_form_params)

    if @custom_form.save
      send_success_json(@custom_form.id, {custom_form_name: @custom_form.form_name})
    else
      send_error_json(nil, @custom_form.errors.full_messages.to_sentence, 400)
    end
  end

  def update
  end

  def destroy
  end

  private

  def custom_form_params
    params.require(:custom_form).permit(:form_name, :image_name)
  end

  def check_owner()
    if self.try(:current_user).try(:id) == @user_id
      return true
    end
    if self.try(:current_resource_owner).try(:id) == @user_id
      return true
    end
    return false
  end
end

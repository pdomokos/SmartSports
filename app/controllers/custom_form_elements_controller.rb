class CustomFormElementsController < ApplicationController
  def index
    @user_id = params[:user_id].to_i
    user = User.find(@user_id)
    if !check_owner()
      send_error_json(@user_id, "Unauthorized", 403)
    end
    custom_form = user.custom_forms.where(:id => params[:custom_form_id].to_i).first
    if !custom_form
      send_error_json(params[:custom_form_id].to_i, "Invalid custom_form_id", 400)
      return
    end
    @elements = custom_form.custom_form_elements
  end

  private

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

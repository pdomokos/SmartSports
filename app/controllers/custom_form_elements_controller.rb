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

  def create
    user_id = params[:user_id].to_i
    user = User.find(user_id)
    form_id = params[:custom_form_id]
    custom_form = user.custom_forms.where(id: form_id)[0]
    elem = params['elementName']
    resourceName = elem.split('_')[0]
    puts params[resourceName].to_json
    custom_form_element = custom_form.custom_form_elements.new
    custom_form_element.property_code = elem
    custom_form_element.defaults = {resourceName => params[resourceName]}.to_json

    if custom_form_element.save
      send_success_json(custom_form_element.id, {custom_form_id: custom_form.id, property_code: elem})
    else
      send_error_json(nil, custom_form_element.errors.full_messages.to_sentence, 400)
    end
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

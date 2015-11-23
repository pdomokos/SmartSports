module CustomFormElementsCommon

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
    elem = CustomFormElement.new(custom_form_element_params)
    elem.custom_form_id=form_id
    # par = params.clone
    # %w(utf8 authenticity_token controller action).each{|k| par.delete(k)}
    # custom_form_element.defaults = par.to_json

    if elem.save
      send_success_json(elem.id, {custom_form_id: custom_form.id, property_code: elem.property_code})
    else
      send_error_json(nil, elem.errors.full_messages.to_sentence, 400)
    end
  end

  def update
    @user_id = params[:user_id].to_i
    user = User.find(@user_id)
    custom_form_id = params[:custom_form_id].to_i
    custom_form_element_id = params[:id].to_i
    cf = user.custom_forms.where(id: custom_form_id).first
    if !cf
      send_error_json(user.id, "custom_form missing", 400)
      return
    end
    cfe = cf.custom_form_elements.where( id: custom_form_element_id ).first
    if !cf
      send_error_json(user.id, "custom_form_element missing", 400)
      return
    end

    # update_hash = {:property_code => params['custom_form_element']['property_code'], :defaults => params['custom_form_element']['defaults']}
    if cfe.update_attributes(custom_form_element_params)
      send_success_json(cfe.id)
    else
      send_error_json(cfe.id, cfe.errors.full_messages.to_sentence, 400)
    end
  end

  def destroy
    @user_id = params[:user_id].to_i
    user = User.find(@user_id)
    if !check_owner()
      send_error_json(@user_id, "Unauthorized", 403)
      return
    end
    cf = user.custom_forms.where(id: params[:custom_form_id].to_i).first
    if !cf
      send_error_json(params[:id].to_i, "custom_form missing", 400)
      return
    end
    cfe = cf.custom_form_elements.where(id: params[:id]).first
    if !cfe
      send_error_json(params[:id].to_i, "custom_form_element missing", 400)
      return
    end
    if cfe.destroy
      send_success_json(cfe.id)
    else
      send_error_json(cfe.id, "custom_form_element delete_failed", 400)
    end
  end

  private

  def custom_form_element_params
    params.require(:custom_form_element).permit(:property_code, :defaults, :order_index)
  end

end
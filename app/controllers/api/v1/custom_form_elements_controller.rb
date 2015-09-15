module Api::V1
  class CustomFormElementsController < ApiController
    before_action :set_activity, only: [ :update, :destroy]

    def create
      user_id = params[:user_id].to_i
      user = User.find(user_id)
      custom_form_id = params[:custom_form_id].to_i
      custom_form = user.custom_forms.where(:id => custom_form_id).first

      custom_form_element = custom_form.custom_form_elements.build(custom_form_element_params)

      if custom_form_element.save
        send_success_json(custom_form_element.id, {property_code: custom_form_element.property_code})
      else
        send_error_json(nil, custom_form_element.errors.full_messages.to_sentence, 400)
      end
    end

    private

    def custom_form_element_params
      params.require(:custom_form_element).permit(:property_code, :template_id)
    end

  end
end
class FormElementController < ApplicationController
  respond_to :js

  def show
    @formName = params[:form_name]
    @targetElementSelector = params[:target_element_selector]
    @form_params = CustomForm.form_params
    @formButton = true
    if params[:form_button]
      @formButton = (params[:form_button]=="true")
    end
    if CustomForm.form_list.include?(@formName)
    else
      render 'error'
    end
  end
end

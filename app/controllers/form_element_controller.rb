class FormElementController < ApplicationController
  respond_to :js

  def show
    @formName = params[:form_name]
    @form_params = CustomForm.form_params
    @targetElementSelector = "#openModalAddCustomFormElement .dataForm"
    if CustomForm.form_list.include?(@formName)
    else
      render 'error'
    end
  end
end

class CustomMedicationTypesController < ApplicationController
  def index
    user_id = params[:user_id]
    custom_medication_type_ids = Medication.select("custom_medication_type_id").where("user_id = ?",user_id)
    @custom_medication_types = CustomMedicationType.where(id: custom_medication_type_ids)
    render :template => 'custom_medication_types/index.json'
  end

  def show
    id = params[:id]
    @custom_medication_type = CustomMedicationType.find_by_id(id)
    render :template => 'custom_medication_types/show.json'
  end
end

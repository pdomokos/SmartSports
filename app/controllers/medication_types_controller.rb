class MedicationTypesController < ApplicationController
  respond_to :json

  def index
    medication_types = MedicationType.all
    render json: medication_types
  end

end
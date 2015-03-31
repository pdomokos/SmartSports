module Api::V1
  class MedicationTypesController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!, only: [:index]
    respond_to :json

    def index
      medication_types = MedicationType.all
      render json: medication_types
    end
  end
end

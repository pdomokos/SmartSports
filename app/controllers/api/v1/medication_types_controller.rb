module Api::V1
  class MedicationTypesController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!, only: [:index]
    respond_to :json

    def index
      group = params[:group]
      limit = params[:limit]
      medication_types = MedicationType.all
      if group && group=='oral'
        medication_types = medication_types.where(group: 'oral')
      elsif group && group=='insulin'
        medication_types = medication_types.where(group: 'insulin')
      end
      if limit && limit.to_i>0
        medication_types = medication_types.limit(limit.to_i)
      end

      render json: medication_types
    end
  end
end

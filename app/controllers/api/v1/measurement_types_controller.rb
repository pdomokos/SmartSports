module Api::V1
  class MeasurementTypesController < ApiController
    respond_to :json
    include MeasurementTypesCommon
  end
end

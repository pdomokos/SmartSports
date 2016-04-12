module Api::V1
  class GeneticsRecordTypesController < ApiController
    respond_to :json
    include GeneticsRecordTypesCommon
  end
end

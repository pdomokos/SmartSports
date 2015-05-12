class IllnessTypesController < ApplicationController
  respond_to :json

  def index
    id = params[:id]
    limit = params[:limit]
    if id
      illness_types = IllnessType.where("id = '#{id}'")
    else
      illness_types = IllnessType.all
    end
    if limit
      illness_types = illness_types.limit(limit)
    end
    render json: illness_types
  end

end
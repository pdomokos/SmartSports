module Api::V1
  class ActivityTypesController < ApiController
    rescue_from Exception, :with => :general_error_handler
    before_action :doorkeeper_authorize!, only: [:index]
    respond_to :json

    def index
      category = params[:category]
      limit = params[:limit]
      activity_types = ActivityType.all
      if category && category=='sport'
        activity_types = activity_types.where(category: 'sport')
      elsif category && category=='other'
        activity_types = activity_types.where("category != 'sport'")
      end
      if limit && limit.to_i>0
        activity_types = activity_types.limit(limit.to_i)
      end

      render json: activity_types
    end
  end
end

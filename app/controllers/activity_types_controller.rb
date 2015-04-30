class ActivityTypesController < ApplicationController
  respond_to :json

  def index
    id = params[:id]
    category = params[:category]
    limit = params[:limit]
    if id
      activity_types = ActivityType.where("id = '#{id}'")
    else
      if category == 'sport'
        activity_types = ActivityType.where("category = 'sport'")
      elsif category == 'other'
        activity_types = ActivityType.where("category != 'sport'")
      end
    end
    if limit
      activity_types = activity_types.limit(limit)
    end
    render json: activity_types
  end

end
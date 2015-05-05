class ActivityTypesController < ApplicationController
  respond_to :json

  def index
    id = params[:id]
    category = params[:category]
    limit = params[:limit]
    if id
      activity_types = ActivityType.where("id = '#{id}'")
    else
      activity_types = ActivityType.all
      if category == 'sport'
        activity_types = activity_types.where("category = 'sport'")
      elsif category == 'other'
        activity_types = activity_types.where("category != 'sport'")
      end
    end
    if limit
      activity_types = activity_types.limit(limit)
    end
    render json: activity_types
  end

end
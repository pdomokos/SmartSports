class AnalysisDataController < ApplicationController
  respond_to :json

  def index
    user_id = params[:user_id]

    result = []
    user = User.find(user_id)
    activities = user.activities
    if params[:date]
      date = params[:date]
      activities = activities.where("start_time between '#{date} 00:00:00' and '#{date} 23:59:59'")
    end
    result.concat(activities.collect{|act| {
                      id: act.id,
                      title: act.try(:activity_type).try(:name),
                      depth: 0,
                      dates: [act.start_time, act.end_time],
                      evt_type: 'exercise'
                  }})

    diets = user.diets
    if params[:date]
      date = params[:date]
      diets = diets.where("date between '#{date} 00:00:00' and '#{date} 23:59:59'")
    end
    result.concat(diets.collect{|diet| {
                      id: diet.id,
                      title: diet.try(:food_type).try(:name),
                      depth: 0,
                      dates: [diet.date],
                      evt_type: 'diet'
                  }})

    measurements = user.measurements
    if params[:date]
      date = params[:date]
      measurements = measurements.where("date between '#{date} 00:00:00' and '#{date} 23:59:59'")
    end
    result.concat(measurements.collect{|meassurement| {
                      id: meassurement.id,
                      title: meassurement.get_title,
                      depth: 0,
                      dates: [meassurement.date],
                      evt_type: 'measurement'
                  }})

    lifestyles = user.lifestyles.where(group: 'sleep')
    if params[:date]
      date = params[:date]
      lifestyles = lifestyles.where("(start_time between '#{date} 00:00:00' and '#{date} 23:59:59') OR (end_time between '#{date} 00:00:00' and '#{date} 23:59:59')" )
    end
    result.concat(lifestyles.collect{|lifestyle| {
                      id: lifestyle.id,
                      title: lifestyle.tooltip,
                      depth: 0,
                      dates: [lifestyle.start_time, lifestyle.end_time],
                      evt_type: 'lifestyle'
                  }})

    render json: result
  end
end

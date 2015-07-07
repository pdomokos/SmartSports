module DashboardHelper
  def get_thisweek_summary()
    @calories_taken = Diet.where("user_id = :user_id AND date >= :start_date", {user_id: current_user.id, start_date: (DateTime.now-1.week)})
                          .sum("calories").round(2)
    @calories_burned = Activity.where("user_id = :user_id AND start_time >= :start_date", {user_id: current_user.id, start_date: (DateTime.now-1.week)})
                           .sum("calories").round(2)
    @steps_walked = Activity.where("user_id = :user_id AND start_time >= :start_date", {user_id: current_user.id, start_date: (DateTime.now-1.week)})
                        .sum("steps")

  end

  def get_todays_summary()
    @calories_taken = Diet.where(user_id: current_user.id).where("date between ? and ?", Time.zone.now.midnight, Time.zone.now.midnight+1.day)
                          .sum("calories").round
    if @calories_taken>0
      calories_yesterday = Diet.where(user_id: current_user.id).where("date between ? and ?", Time.zone.now.midnight-1.day, Time.zone.now.midnight)
                               .sum("calories").round

      @calories_diff = (@calories_taken-calories_yesterday)

      if calories_yesterday>0
        calories_diff_percent = @calories_diff.to_f/calories_yesterday
        @calories_diff_percent = sprintf("%+.1f%%", calories_diff_percent*100.0)
      end

      @calories_diff_show = (calories_yesterday>0) && @calories_taken>0
      @calories_status = "improve"
      @calories_arrow = "down"
      if @calories_diff>0
        @calories_status = "worsen"
        @calories_arrow = "up"
      end
    end

    @calories_burned = Activity.where(user_id: current_user.id).where("start_time between ? and ?", Time.zone.now.midnight, Time.zone.now.midnight+1.day)
                           .sum("calories").round(2)
    @steps_walked = Activity.where("user_id = :user_id AND start_time >= :start_date", {user_id: current_user.id, start_date: (DateTime.now-1.week)})
                        .sum("steps")

  end

end
module PagesHelper

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
                          .sum("calories").round(2)
    @calories_burned = Activity.where(user_id: current_user.id).where("start_time between ? and ?", Time.zone.now.midnight, Time.zone.now.midnight+1.day)
                           .sum("calories").round(2)
    @steps_walked = Activity.where("user_id = :user_id AND start_time >= :start_date", {user_id: current_user.id, start_date: (DateTime.now-1.week)})
                        .sum("steps")

  end
end

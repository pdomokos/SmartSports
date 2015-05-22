module ActivitiesCommon

  # POST /activities
  # POST /activities.json
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    @activity = user.activities.build(activity_params)
    if not @activity.start_time
      @activity.start_time = DateTime.now
    end
    actType = ActivityType.find_by_id(@activity.activity_type_id)
    if actType.nil?
      send_error_json(nil, "Invalid activity type", 404)
      return
    elsif not @activity.duration
      if @activity.start_time && @activity.end_time
        @activity.duration = ((@activity.end_time-@activity.start_time) / 60).to_i
      end
    end

    if @activity.duration
      @activity.calories = @activity.duration * actType.kcal / 10
      if @activity.intensity == 1.0
        @activity.calories = @activity.calories * 0.8
      elsif @activity.intensity == 3.0
        @activity.calories = @activity.calories * 1.2
      end
    end

    # respond_to do |format|
    if @activity.save
      send_success_json(@activity.id, {activity_name: @activity.activity_type.name})
    else
      send_error_json(nil, @activity.errors.full_messages.to_sentence, 400)
    end
    # end
  end


  # PATCH/PUT /diets/1
  # PATCH/PUT /diets/1.json
  def update
    if @activity.nil?
      send_error_json( @activity.id, "Param 'activity' missing", 400)
      return
    end

    if !check_owner()
      send_error_json(@activity.id, "Unauthorized", 403)
      return
    end

    fav = true
    if params['activity'].nil? || params['activity']['favourite'].nil? || params['activity']['favourite']=='false'
      fav = false
    end
    update_hash = {:favourite => fav}

    if params['activity'] && params['activity']['intensity']
      update_hash[:intensity] = params['activity']['intensity'].to_f
    end

    if params['activity'] && params['activity']['group']
      update_hash[:group] = params['activity']['group']
    end


    if @activity.update_attributes(update_hash)
      send_success_json(@activity.id)
    else
      send_error_json(@activity.id,"Update error", 400)
    end

  end

  # DELETE /diets/1
  # DELETE /diets/1.json
  def destroy

    if @activity.nil?
      send_error_json(nil, "Delete error", 400)
      return
    end

    currid = @activity.id
    if !check_owner()
      send_error_json(currid, "Unauthorized", 403)
      return
    end
    if @activity.destroy
      send_success_json(currid, {})
    else
      send_error_json(currid, "Delete error", 400)
    end
  end

  private

  def check_owner()
    puts "try"
    if self.try(:current_user)
      puts "current_user defined"
    else
      puts "current_user NOT defined"
    end
    if self.try(:current_resource_owner)
      puts "current_resource_owner defined"
    else
      puts "current_resource_owner NOT defined"
    end

    if self.try(:current_user).try(:id) == @activity.user_id
      return true
    end
    if self.try(:current_resource_owner).try(:id) == @activity.user_id
      return true
    end
    return false
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = Activity.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    params.require(:activity).permit(:source, :activity, :group, :game_id, :start_time, :end_time, :steps, :duration, :distance, :calories, :manual, :intensity, :favourite, :activity_type_id)
  end
end
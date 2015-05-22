module ActivitiesCommon

  # PATCH/PUT /diets/1
  # PATCH/PUT /diets/1.json
  def update
    @activity = Activity.find_by_id(params[:id])

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
    @activity = Activity.find_by_id(params[:id])
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
end
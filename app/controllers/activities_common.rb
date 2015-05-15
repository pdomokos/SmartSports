module ActivitiesCommon

  # PATCH/PUT /diets/1
  # PATCH/PUT /diets/1.json
  def update
    @activity = Activity.find_by_id(params[:id])

    if @activity.nil?
      render json: { :ok => false, :msg => "Param 'activity' missing"}, status: 400
      return
    end

    if !check_owner()
      render json: { :ok => false}, status: 403
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

    respond_to do |format|
      if @activity.update_attributes(update_hash)
        format.json { render json: { :ok => true, :msg => "Updated successfully" } }
      else
        format.json { render json: { :ok => false, :msg => "Update errror" }, :status => 400 }
      end
    end

  end

  # DELETE /diets/1
  # DELETE /diets/1.json
  def destroy
    @activity = Activity.find_by_id(params[:id])
    if @activity.nil?
      render json: { :ok => false}, status: 400
      return
    end

    if !check_owner()
      render json: { :ok => false}, status: 403
      return
    end

    respond_to do |format|
      if @activity.destroy
        format.json { render json: { :ok => true, :msg => "Deleted successfully" } }
      else
        format.json { render json: { :ok => false, :msg => "Delete errror" }, :status => 400 }
      end
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
module MeasurementsCommon

  # PATCH/PUT /measurements/1
  # PATCH/PUT /measurements/1.json
  def update
    @measurement = Measurement.find_by_id(params[:id])

    if @measurement.nil?
      send_error_json(nil, "Param 'measurement' missing", 400)
      return
    end

    if !check_owner()
      send_error_json(nil, "Unauthorized", 403)
      return
    end

    fav = true
    if params['measurement'].nil? || params['measurement']['favourite'].nil? || params['measurement']['favourite']=='false'
      fav = false
    end
    update_hash = {:favourite => fav}

    if params['measurement']
      if params['measurement']['systolicbp']
        update_hash[:systolicbp] = params['measurement']['systolicbp'].to_i
      end
      if params['measurement']['diastolicbp']
        update_hash[:diastolicbp] = params['measurement']['diastolicbp'].to_i
      end
      if params['measurement']['pulse']
        update_hash[:pulse] = params['measurement']['pulse'].to_i
      end
      if params['measurement']['blood_sugar']
        update_hash[:blood_sugar] = params['measurement']['blood_sugar'].to_f
      end
      if params['measurement']['weight']
        update_hash[:weight] = params['measurement']['weight'].to_f
      end
      if params['measurement']['waist']
        update_hash[:waist] = params['measurement']['waist'].to_f
      end
    end

    if @measurement.update_attributes(update_hash)
      send_success_json(@measurement.id, {})
    else
      send_error_json(nil, "Update error", 400)
    end

  end

# DELETE /measurements/1
# DELETE /measurements/1.json
  def destroy
    @measurement = Measurement.find(params[:id])
    if @measurement.nil?
      send_error_json(nil, "Delete error", 400)
      return
    end

    if !check_owner()
      send_error_json(@measurement.id, "Unauthorized", 403)
      return
    end

    if @measurement.destroy
      send_success_json(@measurement.id, {})
    else
      send_error_json(@measurement.id, "Delete error", 400)
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

    if self.try(:current_user).try(:id) == @measurement.user_id
      return true
    end
    if self.try(:current_resource_owner).try(:id) == @measurement.user_id
      return true
    end
    return false
  end

end


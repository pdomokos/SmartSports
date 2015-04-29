module MedicationsCommon

  # PATCH/PUT /medications/1
  # PATCH/PUT /medications/1.json
  def update
    @medication = Medication.find_by_id(params[:id])

    if @medication.nil?
      render json: { :ok => false, :msg => "Param 'medication' missing"}, status: 400
      return
    end

    if !check_owner()
      render json: { :ok => false}, status: 403
      return
    end

    fav = true
    if params['medication'].nil? || params['medication']['favourite'].nil? || params['medication']['favourite']=='false'
      fav = false
    end
    update_hash = {:favourite => fav}

    if params['medication'] && params['medication']['amount']
      update_hash[:amount] = params['medication']['amount'].to_i
    end
    if params['medication'] && params['medication']['medication_type_id']
      mt = MedicationType.find_by_id(params['medication']['medication_type_id'].to_i)
      if !mt.nil?
        update_hash[:medication_type_id] = mt.id
      else
        render json: { :ok => false, :msg => "Invalid medication_type_id"}, status: 400
        return
      end
    end

    respond_to do |format|
      if @medication.update_attributes(update_hash)
        format.json { render json: { :ok => true, :msg => "Updated successfully" } }
      else
        format.json { render json: { :ok => false, :msg => "Update errror" }, :status => 400 }
      end
    end

  end

  # DELETE /users/:user_id/medications/:id
  # DELETE /users/:user_id/medications/:id.json
  def destroy
    @medication = Medication.find(params[:id])
    if @medication.nil?
      render json: { :ok => false}, status: 400
      return
    end

    if !check_owner()
      render json: { :ok => false}, status: 403
      return
    end

    respond_to do |format|
      if @medication.destroy
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

    if self.try(:current_user).try(:id) == @medication.user_id
      return true
    end
    if self.try(:current_resource_owner).try(:id) == @medication.user_id
      return true
    end
    return false
  end
end
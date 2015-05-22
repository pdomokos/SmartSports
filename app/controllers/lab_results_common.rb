module LabResultsCommon

  # PATCH/PUT /lab_results/1
  # PATCH/PUT /lab_results/1.json
  def update
    @labresult = LabResult.find_by_id(params[:id])

    if @labresult.nil?
      send_error_json(nil, "Param 'labresult' missing", 400)
      return
    end

    if !check_owner()
      send_error_json(@labresult.id, "Unauthorized", 403)
      return
    end

    if params['labresult'] && params['labresult']['hba1c']
      update_hash[:hba1c] = params['labresult']['hba1c'].to_f
    end
    if params['labresult'] && params['labresult']['ldl_chol']
      update_hash[:ldl_chol] = params['labresult']['ldl_chol'].to_f
    end
    if params['labresult'] && params['labresult']['egfr_epi']
      update_hash[:egfr_epi] = params['labresult']['egfr_epi'].to_f
    end
    if params['labresult'] && params['labresult']['ketone']
      update_hash[:ketone] = params['labresult']['ketone'].to_s
    end

    if @labresult.update_attributes(update_hash)
      send_success_json(@labresult.id, {:msg => "Updated successfully"})
    else
      send_error_json(@labresult.id, "Update error", 400)
    end

  end

  # DELETE /users/:user_id/lab_results/:id
  # DELETE /users/:user_id/lab_results/:id.json
  def destroy
    @labresult = LabResult.find(params[:id])
    if @labresult.nil?
      send_error_json(nil, "Delete error", 400)
      return
    end

    if !check_owner()
      send_error_json(@labresult.id, "Unauthorized", 403)
      return
    end

    if @labresult.destroy
      send_success_json(@labresult.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@labresult.id, "Delete error", 400)
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

    if self.try(:current_user).try(:id) == @labresult.user_id
      return true
    end
    if self.try(:current_resource_owner).try(:id) == @labresult.user_id
      return true
    end
    return false
  end
end
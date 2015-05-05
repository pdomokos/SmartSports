module LabResultsCommon

  # PATCH/PUT /lab_results/1
  # PATCH/PUT /lab_results/1.json
  def update
    @labresult = LabResult.find_by_id(params[:id])

    if @labresult.nil?
      render json: { :ok => false, :msg => "Param 'labresult' missing"}, status: 400
      return
    end

    if !check_owner()
      render json: { :ok => false}, status: 403
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

    respond_to do |format|
      if @labresult.update_attributes(update_hash)
        format.json { render json: { :ok => true, :msg => "Updated successfully" } }
      else
        format.json { render json: { :ok => false, :msg => "Update errror" }, :status => 400 }
      end
    end

  end

  # DELETE /users/:user_id/lab_results/:id
  # DELETE /users/:user_id/lab_results/:id.json
  def destroy
    @labresult = LabResult.find(params[:id])
    if @labresult.nil?
      render json: { :ok => false}, status: 400
      return
    end

    if !check_owner()
      render json: { :ok => false}, status: 403
      return
    end

    respond_to do |format|
      if @labresult.destroy
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

    if self.try(:current_user).try(:id) == @labresult.user_id
      return true
    end
    if self.try(:current_resource_owner).try(:id) == @labresult.user_id
      return true
    end
    return false
  end
end
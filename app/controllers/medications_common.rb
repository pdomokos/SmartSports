module MedicationsCommon

  # POST /users/[user_id]/medications
  # POST /users/[user_id]/medications.json
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    name = params['medication']['name']
    custom_name = params['medication']['custom_name']
    params[:medication].delete :name
    params[:medication].delete :custom_name
    medication = user.medications.build(medication_params)
    if(name != nil && name != "")
      mt = MedicationType.find_by_name(name)
      medication.medication_type = mt
    elsif(custom_name != nil && custom_name != "")
      cmt = CustomMedicationType.find_by_name(custom_name)
      if cmt == nil || (cmt.category=='custom_insulin' && params[:elementName] == "medication_drugs") || (cmt.category=='custom_drug' && params[:elementName] == "medication_insulin")
        cmt = CustomMedicationType.new
        if params[:elementName] == "medication_insulin"
          cmt.category = "custom_insulin"
        elsif params[:elementName] == "medication_drugs"
          cmt.category = "custom_drug"
        else
          cmt.category = "custom"
        end
        cmt.name = custom_name
        uniqId = SecureRandom.urlsafe_base64(16)
        cmt.key = uniqId
      end
      medication.custom_medication_type = cmt
    end

    if medication.save
      if medication.medication_type
        mt = MedicationType.find(medication.medication_type.name)
        send_success_json(medication.id, {medication_name: mt.title})
      else
        cmt = CustomMedicationType.where(key: cmt.key).first
        send_success_json(medication.id, {medication_name: cmt.name})
      end
    else
      send_error_json(medication.id, medication.errors.full_messages.to_sentence, 400)
    end

  end

  # PATCH/PUT /medications/1
  # PATCH/PUT /medications/1.json
  def update
    @medication = Medication.find_by_id(params[:id])
    @user_id = @medication.user_id

    if @medication.nil?
      send_error_json(nil, "Param 'medication' missing", 400)
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
        send_error_json(nil, "Invalid medication_type_id", 400)
        return
      end
    end

    if @medication.update_attributes(update_hash)
      send_success_json(@medication.id, {:msg => "Updated successfully"})
    else
      send_error_json(@medication.id, "Update error", 400)
    end

  end

  # DELETE /users/:user_id/medications/:id
  # DELETE /users/:user_id/medications/:id.json
  def destroy
    @medication = Medication.find(params[:id])
    @user_id = @medication.user_id
    if @medication.nil?
      send_error_json(nil, "Delete error", 400)
      return
    end

    # if @medication.custom_medication_type_id != nil
    #    cmt = CustomMedicationType.find(@medication.custom_medication_type_id)
    #    cmt.destroy
    # end

    if @medication.destroy
      send_success_json(@medication.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@medication.id, "Delete error", 400)
    end

  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def medication_params
    params.require(:medication).permit(:user_id, :source, :name, :amount, :date, :favourite)
  end

end
module PersonalRecordsCommon

  # POST /users/:id/personal_records
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    @personal_records = user.personal_records.build(genetics_params)

    if @personal_records.save
      send_success_json(@personal_records.id)
    else
      send_error_json(nil, @personal_records.errors.full_messages.to_sentence, 400)
    end

  end

  # DELETE /users/:user_id/personal_records/:id
  def destroy
    set_genetics
    if @personal_records.destroy
      send_success_json(@personal_records.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@personal_records.id, "Delete error", 400)
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_genetics
    @personal_records = PersonalRecord.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def genetics_params
    params.require(:personal_record).permit(:source, :diabetes_key, :antibody_key, :note, :antibody_kind, :antibody_value)
  end
end

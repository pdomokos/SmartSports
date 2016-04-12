module FamilyRecordsCommon

  # POST /users/:id/family_records
  def create
    user_id = params[:user_id]
    user = User.find(user_id)
    @family_records = user.family_records.build(genetics_params)

    if @family_records.save
      send_success_json(@family_records.id)
    else
      send_error_json(nil, @family_records.errors.full_messages.to_sentence, 400)
    end

  end

  # DELETE /users/:user_id/family_records/:id
  def destroy
    set_genetics
    if @family_records.destroy
      send_success_json(@family_records.id, {:msg => "Deleted successfully"})
    else
      send_error_json(@family_records.id, "Delete error", 400)
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_genetics
    @family_records = FamilyRecord.find_by_id(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def genetics_params
    params.require(:family_record).permit(:source, :relative_key, :diabetes_key, :note)
  end
end

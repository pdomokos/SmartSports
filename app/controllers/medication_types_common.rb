module MedicationTypesCommon
  def index
    @medication_types = MedicationType.all
    limit = params[:limit]
    if limit
      @medication_types = @medication_types.limit(limit.to_i)
    end
    render :template => 'medication_types/index.json'
  end

  def show
    id = params[:id]
    @medication_type = MedicationType.find_by_id(id)
    render :template => 'medication_types/show.json'
  end
end

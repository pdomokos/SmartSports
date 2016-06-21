module MeasurementTypesCommon
  def index
    measurement_types = MeasurementType.all
    limit = params[:limit]
    if limit
      measurement_types = measurement_types.limit(limit)
    end

    ret = measurement_types.map { |at|
      puts at.name
      puts at.category
      to_item(at)
    }

    render json: ret
  end

  def show
    id = params[:id]
    lt = MeasurementType.find_by_id(id)
    render json: to_item(lt)
  end

  private

  def to_item(lt)
    {
        name: lt.name,
        category: lt.category,
        hu: DB_HU_CONFIG['measurement'][lt['category']][lt['name']],
        en: DB_EN_CONFIG['measurement'][lt['category']][lt['name']]
    }
  end
end
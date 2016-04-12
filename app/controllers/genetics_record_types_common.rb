module GeneticsRecordTypesCommon
  def index
    genetics_record_types = get_genetics_record_types()
    ret = genetics_record_types.map { |at|
      to_item(at)
    }

    render json: ret
  end

  def show
    id = params[:id]
    genetics_record_types = get_genetics_record_types()
    gt = genetics_record_types.select {|record| record["id"] = id }
    render json: to_item(gt[0])
  end

  private

  def get_genetics_record_types()
    [{id: 1, name: "diabtype1", category: "diabetes"},
     {id: 2, name: "diabtype2", category: "diabetes"},
     {id: 3, name: "diabtype3", category: "diabetes"},
     {id: 4, name: "diabtype4", category: "diabetes"},
     {id: 5, name: "diabtype5", category: "diabetes"},
     {id: 6, name: "diabtype6", category: "diabetes"},
     {id: 7, name: "diabtype7", category: "diabetes"},
     {id: 8, name: "diabtype8", category: "diabetes"},
     {id: 9, name: "antibodytype1", category: "autoantibody"},
     {id: 10, name: "antibodytype2", category: "autoantibody"},
     {id: 11, name: "antibodytype3", category: "autoantibody"},
     {id: 12, name: "antibodytype4", category: "autoantibody"},
     {id: 13, name: "antibodytype5", category: "autoantibody"},
     {id: 14, name: "antibodytype6", category: "autoantibody"},
     {id: 15, name: "reltype1", category: "relatives"},
     {id: 16, name: "reltype2", category: "relatives"},
     {id: 17, name: "reltype3", category: "relatives"},
     {id: 18, name: "reltype4", category: "relatives"},
     {id: 19, name: "reltype5", category: "relatives"}
    ]
  end

  def to_item(gt)
    {
        name: gt[:name],
        category: gt[:category],
        hu: DB_HU_CONFIG['genetics'][gt[:category]][gt[:name]],
        en: DB_EN_CONFIG['genetics'][gt[:category]][gt[:name]]
    }
  end
end
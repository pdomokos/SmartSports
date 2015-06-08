module DataHelper

  def dup_data( from_uid = 1 , to_uid = 15)
    u = User.find_by_id(from_uid)
    u.diets.each do |it|
      if it.type=='Smoke' || it.food_type
        d = it.dup
        d.user_id = to_uid
        d.save!
      end
    end

    # dup_summaries
    arr = Summary.where(user_id: from_uid)
    arr.each do |s|
      snew = s.dup
      snew.user_id = to_uid
      snew.save
    end

    # ========================
    u.measurements.each do |it|
      d = it.dup
      d.user_id = to_uid
      d.save!
    end

    u.activities.each do |it|
      if it.activity_type
        d = it.dup
        d.user_id = to_uid
        d.save!
      end
    end
  end


  # ========================
  def export_food_types
    arr = FoodType.all
    File.open("/data/tmp/food_types.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def import_food_types
    File.open('/Users/bdomokos/Downloads/tmp/food_types.json', 'r') do |f|
      arr = JSON.parse(f.read())
      arr.each do |d|
        at = FoodType.create(d)
      end
    end
  end


  def export_diets
    from_uid = 1
    u = User.find_by_id(from_uid)
    arr = u.diets.select { |it| it.type=='Smoke' || it.food_type }
    File.open("/data/tmp/diets_uid_1.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def export_exercise
    from_uid = 1
    u = User.find_by_id(from_uid)
    arr = u.activities.select { |it| it.activity_type }
    File.open("/data/tmp/activities_uid_1.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def export_activity_types
    arr = ActivityType.all
    File.open("/data/tmp/activity_types.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end
  def import_activity_types
    File.open('/Users/bdomokos/Downloads/tmp/activity_types.json', 'r') do |f|
      arr = JSON.parse(f.read())
      arr.each do |d|
        at = ActivityType.create(d)
      end
    end
  end

  def export_health
    from_uid = 1
    u = User.find_by_id(from_uid)
    arr = u.measurements.all
    File.open("/data/tmp/measurements_uid_#{from_id}.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def export_medications
    from_uid = 1
    u = User.find_by_id(from_uid)
    arr = u.medications.select {|it| it.medication_type}
    File.open("/data/tmp/medications_uid_1.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def export_wellbeing
    from_uid = 1
    u = User.find_by_id(from_uid)
    arr = u.lifestyles.select { |it| it.group == 'sleep' }
    File.open("/data/tmp/lifestyles_uid_1.json", 'w') do |f|
      JSON.dump(arr.as_json, f)
    end
  end

  def import_data(model, uid)
    u = User.find_by_id(uid)
    arr = nil
    path = File.join('/Users/bdomokos/Downloads/tmp/', "#{model}_uid_1.json")
    File.open(path, 'r') do |f|
      arr = JSON.parse(f.read())
      arr.each do |d|
        u.try(model.to_sym).create(d)
      end
    end
  end
end

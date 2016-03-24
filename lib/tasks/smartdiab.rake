require 'json'
require 'csv'

namespace :smartdiab do

  task init_db: :environment do
    Rake::Task['smartdiab:init_activity'].execute
    Rake::Task['smartdiab:init_food'].execute
    Rake::Task['smartdiab:init_genetics'].execute
    Rake::Task['smartdiab:init_labresult'].execute
    Rake::Task['smartdiab:init_lifestyle'].execute
    if InitVersion.all.size == 1
      actualVersion = InitVersion.last
      actualVersion.update(:version_number => actualVersion.version_number+1)
    else
      InitVersion.all.delete_all
      v = InitVersion.new(:id => 1, :version_number =>  1)
      v.save!
    end
  end

  task init_medication: :environment do
    if MedicationType.all.size != 0
      MedicationType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_medication.csv"
    csv = CSV.read(csv_text, headers: true, col_sep: ",")
    csv.each do |row|
      if row['name'].size < 100
        MedicationType.create!(row.to_hash)
      end
    end
  end

  task init_activity: :environment do
    if ActivityType.all.size != 0
      ActivityType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_activity.csv"
    csv = CSV.read(csv_text, headers: true, col_sep: ";")
    csv.each do |row|
      ActivityType.create!(row.to_hash)
    end
  end

  task init_food: :environment do
    if FoodType.all.size != 0
      FoodType.all.delete_all
    end

    foodList = nil
    dirName = File.dirname(__FILE__)
    f = dirName + "/init_food.csv"
    foodList = CSV.read(f, headers: true, col_sep: ";")

    foodList.each do |m|
      FoodType.create!(m.to_hash)
    end

  end

  task init_genetics: :environment do
    if GeneticsType.all.size != 0
      GeneticsType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_genetics.csv"
    csv = CSV.read(csv_text, headers: true, col_sep: ";")
    csv.each do |row|
      GeneticsType.create!(row.to_hash)
    end
  end

  task init_labresult: :environment do
    if LabresultType.all.size != 0
      LabresultType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_labresult.csv"
    csv = CSV.read(csv_text, headers: true, col_sep: ";")
    csv.each do |row|
      LabresultType.create!(row.to_hash)
    end
  end

  task init_lifestyle: :environment do
    if LifestyleType.all.size != 0
      LifestyleType.all.delete_all
    end

    dirName = File.dirname(__FILE__)
    csv_text = dirName + "/init_lifestyle.csv"
    csv = CSV.read(csv_text, headers: true, col_sep: ";")
    csv.each do |row|
      LifestyleType.create!(row.to_hash)
    end
  end

end

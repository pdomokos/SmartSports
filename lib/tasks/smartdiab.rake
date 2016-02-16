require 'json'
require 'csv'

namespace :smartdiab do
  "Load default medications"
  task init_medication: :environment do
    if MedicationType.all.size != 0
      MedicationType.all.each {|mt|
        mt.destroy!
      }
    end

    insulin = Regexp.new(/insulin/)
    injection = Regexp.new(/injekc/)

    File.open("#{ENV['HOME']}/Downloads/medications.json") do |f|
      medlist = JSON.load(f)

      #print medlist.first.as_json.pretty_inspect
      medlist.each do |m|

        grp = "oral"
        if insulin === m['substance']
          grp = "insulin"
        else
          if injection === m['name'] or m['name'].start_with?('[')
            next
          end
        end

        mt = MedicationType.new(:name =>  m['name'], :group => grp)
        mt.save!
      end
    end
  end

  task init_activity: :environment do
    if ActivityType.all.size != 0
      ActivityType.all.each {|at|
        at.destroy!
      }
    end

    csv_text = File.read("#{ENV['HOME']}/Downloads/activities.csv")
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      ActivityType.create!(row.to_hash)
    end
  end

  task init_foods: :environment do
    if FoodType.all.size != 0
      FoodType.all.each {|mt|
        mt.destroy!
      }
    end

    foodlist = nil
    File.open("#{ENV['HOME']}/Downloads/foods_exported.json") do |f|
      foodlist = JSON.load(f)

      #print foodlist.first.as_json.pretty_inspect
      foodlist.each do |m|
        # ["id", "name", "category", "amount", "kcal", "prot", "carb", "fat"]
        ft = FoodType.new(:id => m['id'], :name =>  m['name'], :category => m['category'], :amount => m['amount'], :kcal => m['kcal'], :prot => m['prot'], :carb => m['carb'], :fat => m['fat'])
        ft.save!
      end
    end
  end

  task init_foods_simple: :environment do
    if FoodType.all.size != 0
      FoodType.all.each {|mt|
        mt.destroy!
      }
    end

    foodlist = nil
    dirName = File.dirname(__FILE__)
    f = dirName + "/init_food.csv"
    foodlist = CSV.read(f, headers: true, col_sep: ";")

    #print foodlist.first.as_json.pretty_inspect
    foodlist.each do |m|
      # ["name", "category", "lang"]
      ft = FoodType.new(:name => m['name'], :category =>  m['category'], :lang => m['lang'])
      ft.save!
    end

  end

  task load_foods_csv: :environment do
    if FoodType.all.size != 0
      FoodType.all.each {|mt|
        mt.destroy!
      }
    end

    foodlist = nil
    f = "#{ENV['HOME']}/Downloads/foods_exported_final.csv"
    foodlist = CSV.read(f, headers: true)

    #print foodlist.first.as_json.pretty_inspect
    foodlist.each do |m|
      # ["id", "name", "category", "amount", "kcal", "prot", "carb", "fat"]
      ft = FoodType.new(:id => m['ID'], :name =>  m['Description'], :category => m['Category'], :amount => m['Quantity'], :kcal => m['Kcal'], :prot => m['Protein'], :carb => m['Carb'], :fat => m['Fat'])
      ft.save!
    end

  end

  task load_illness_csv: :environment do
    if IllnessType.all.size != 0
      IllnessType.all.each {|mt|
        mt.destroy!
      }
    end

    illnesslist = nil
    f = "#{ENV['HOME']}/Downloads/illnesses.csv"
    illnesslist = CSV.read(f, headers: true)

    #print foodlist.first.as_json.pretty_inspect
    i = 0
    illnesslist.each do |m|
      # ["id", "name", "category", "amount", "kcal", "prot", "carb", "fat"]
      ft = IllnessType.new(:id => i, :name =>  m['Name'])
      ft.save!
      i += 1
    end

  end

  task export_foods: :environment do
    k = ["id", "name", "category", "amount", "kcal", "prot", "carb", "fat"]
    CSV.open("#{ENV['HOME']}/Downloads/foods_exported.csv", 'w') do |csv|
      csv << k
      prev = nil
      FoodType.all.order("name").order("kcal").each do |ft|
        row = ft.as_json
        cmp = row.clone
        cmp.delete('id')
        if cmp!=prev
          prev=cmp
          csv << k.map{|it| row[it]}
        end
      end
    end
  end

  task export_json: :environment do
    File.open("#{ENV['HOME']}/Downloads/foods_exported.json", 'w') do |f|
      arr = []
      prev = nil
      FoodType.all.order("name").order("kcal").each do |ft|
        curr = ft.as_json
        cmp = curr.clone
        cmp.delete('id')
        if cmp!=prev
          arr << curr
          prev = cmp
        end
      end
      JSON.dump(arr, f)
    end
  end

  task export_activities: :environment do
    k = ["name", "kcal", "category"]
    CSV.open("#{ENV['HOME']}/Downloads/activity_exported.csv", 'w') do |csv|
      csv << k
      prev = nil
      ActivityType.all.order("id").each do |at|
        row = at.as_json
        cmp = row.clone
        cmp.delete('id')
        if cmp!=prev
          prev=cmp
          csv << k.map{|it| row[it]}
        end
      end
    end
  end
end

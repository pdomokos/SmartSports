class DietValidator < ActiveModel::Validator
  def validate(record)
    if (record.diet_type == 'Food' || record.diet_type == 'Drink') && record.food_type_id == nil
      record.errors[:food_type_id] << 'No value'
    elsif record.diet_type == 'Calory' && ((record.calories == nil || record.calories == "") && (record.carbs == nil || record.carbs == ""))
      record.errors[:calories] << 'No value'
    elsif record.diet_type == 'Smoke' && (record.name == nil || record.name == "")
      record.errors[:name] << 'No value'
    end
  end
end

class Diet < ActiveRecord::Base
  belongs_to :user
  belongs_to :food_type
  validates :user_id, presence: true
  validates_with DietValidator

  def as_json(options={})
    super(options.merge({:methods => :diet_type}))
  end

  def diet_name
    if self.name!=nil
      return self.name
    end
    name = nil
    if self.diet_type=="Smoke" or self.diet_type=="Calory"
      name = self.name
    else
      name = self.try(:food_type).try(:name)
    end

    return name
  end

end

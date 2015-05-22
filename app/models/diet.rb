class DietValidator < ActiveModel::Validator
  def validate(record)
    if (record.type == 'Food' || record.type == 'Drink') && record.food_type_id == nil
      record.errors[:food_type_id] << 'No value'
    elsif record.type == 'Smoke' && (record.name == nil || record.name == "")
      record.errors[:name] << 'No value'
    end
  end
end

class Diet < ActiveRecord::Base
  belongs_to :user
  validates :user_id, presence: true
  validates_with DietValidator

  def as_json(options={})
    super(options.merge({:methods => :type}))
  end

  def diet_name
    name = nil
    if self.type=="Smoke"
      name = self.name
    else
      name = self.try(:food_type).try(:name)
    end

    return name
  end

end

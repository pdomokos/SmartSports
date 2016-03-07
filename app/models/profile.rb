class ProfileValidator < ActiveModel::Validator
  def validate(record)
    if record.dateofbirth
      if record.dateofbirth < 1900 or record.dateofbirth > 2016
        record.errors[:base] << "error_profile_year_interval"
      end
    end
    if record.weight
      if record.weight < 20 or record.weight > 500
        record.errors[:base] << "error_profile_weight_interval"
      end
    end
    if record.height
      if record.height < 100 or record.height > 250
        record.errors[:base] << "error_profile_height_interval"
      end
    end
  end
end

class Profile < ActiveRecord::Base
  belongs_to :user
  validates :dateofbirth, numericality: { only_integer: true,message: "error_profile_year_format" }, allow_nil: true
  validates :weight, numericality: {message: "error_profile_weight_format"}, allow_nil: true
  validates :height, numericality: {message: "error_profile_height_format"}, allow_nil: true
  validates_with ProfileValidator
end

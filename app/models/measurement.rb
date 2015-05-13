class MeasValidator < ActiveModel::Validator
  def validate(record)
    if record.meas_type == 'blood_pressure' && (record.systolicbp == nil || record.diastolicbp == nil || record.pulse == nil)
      record.errors[:systolicbp] << 'No value'
    elsif record.meas_type == 'blood_sugar' && record.blood_sugar == nil
      record.errors[:blood_sugar] << 'No value'
    elsif record.meas_type == 'weight' && record.weight == nil
      record.errors[:weight] << 'No value'
    elsif record.meas_type == 'waist' && record.waist == nil
      record.errors[:waist] << 'No value'
    end
  end
end

class Measurement < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true
  validates :systolicbp, :numericality => true, :allow_nil => true
  validates :diastolicbp, :numericality => true, :allow_nil => true
  validates :pulse, :numericality => true, :allow_nil => true
  validates :blood_sugar, :numericality => true, :allow_nil => true
  validates :weight, :numericality => true, :allow_nil => true
  validates :waist, :numericality => true, :allow_nil => true
  # validates :SPO2, :numericality => true
  validates_with MeasValidator

end

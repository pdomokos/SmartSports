class MeasValidator < ActiveModel::Validator
  def validate(record)
    if record.meas_type == 'blood_pressure' &&
        ((record.systolicbp == nil && record.diastolicbp == nil && record.pulse == nil) ||
        (record.systolicbp != nil && record.diastolicbp == nil)||(record.systolicbp == nil && record.diastolicbp != nil))
      record.errors[:systolicbp] << 'Invalid blood pressure and pulse measurements'
    elsif record.meas_type == 'blood_sugar' && record.blood_sugar == nil
      record.errors[:blood_sugar] << 'Missing blood sugar value'
    elsif record.meas_type == 'weight' && record.weight == nil
      record.errors[:weight] << 'Missing weight value'
    elsif record.meas_type == 'waist' && record.waist == nil
      record.errors[:waist] << 'Missing waist value'
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

  def get_title
    result = self.meas_type
    if self.meas_type == 'blood_pressure'
      if self.systolicbp.nil? && !self.pulse.nil?
        result = "Heart rate: #{self.pulse}"
      elsif !self.systolicbp.nil? && self.pulse.nil?
        result = "Systolic/Diastolic: #{self.systolicbp}/#{self.diastolicbp}"
      else
        result = "Systolic/Diastolic/HR: #{self.systolicbp}/#{self.diastolicbp}/#{self.pulse}"
      end
    end
    return result
  end
end

class LabValidator < ActiveModel::Validator
  def validate(record)
    if record.category == 'hba1c' && (record.hba1c == nil)
      record.errors[:hba1c] << 'No value'
    elsif record.category == 'ldl_chol' && (record.ldl_chol == nil)
      record.errors[:ldl_chol] << 'No value'
    elsif record.category == 'egfr_epi' && (record.egfr_epi == nil)
      record.errors[:egfr_epi] << 'No value'
    elsif record.category == 'ketone' && (record.ketone == nil || record.ketone == "")
      record.errors[:ketone] << 'No value'
    end
  end
end

class LabResult < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true, :allow_nil => true
  validates :hba1c, :numericality => true, :allow_nil => true
  validates :ldl_chol, :numericality => true, :allow_nil => true
  validates :egfr_epi, :numericality => true, :allow_nil => true
  validates_with LabValidator
end

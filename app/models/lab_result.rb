class LabValidator < ActiveModel::Validator

  def validate(record)
    if record.category == 'hba1c' && (record.hba1c == nil)
      record.errors[:hba1c] << 'no_value'
    elsif record.category == 'ldl_chol' && (record.ldl_chol == nil)
      record.errors[:ldl_chol] << 'no_value'
    elsif record.category == 'egfr_epi' && (record.egfr_epi == nil)
      record.errors[:egfr_epi] << 'no_value'
    elsif record.category == 'ketone' && (record.ketone == nil || record.ketone == "")
      record.errors[:ketone] << 'no_value'
    end

    if record.invalid_date
      print "set invalid #{@invalid_date}"
      record.errors[:date] << 'invalid'
    elsif record.date.nil?
      print "set missing"
      record.errors[:date] << 'missing'
    end

  end
end

class LabResult < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true, :allow_nil => true
  validates :hba1c, :numericality => {message: 'should_be_number'}, :allow_nil => true
  validates :ldl_chol, :numericality => {message: 'should_be_number'}, :allow_nil => true
  validates :egfr_epi, :numericality => {message: 'should_be_number'}, :allow_nil => true
  #validates :date, :presence => false, :allow_nil => true
  validates_with LabValidator

  def date=(datestr)
    val = Chronic.parse(datestr)
    if !datestr.nil? && val.nil?
      @invalid_date = true
    end
    self.send(:write_attribute, :date, val)
  end

  def invalid_date
    return @invalid_date
  end
end

class MedicationTypeValidator < ActiveModel::Validator
  def validate(record)
    if record.medication_type_id == nil && record.custom_medication_type_name == nil
      record.errors[:medication_type] << 'Invalid medication type'
    end
  end
end

class Medication < ActiveRecord::Base
  belongs_to :user
  belongs_to :medication_type
  belongs_to :custom_medication_type
  validates :user_id, :presence => true
  validates :date, :presence => true
  validates :amount, :numericality => true, :allow_nil => true
  validates_with MedicationTypeValidator
end

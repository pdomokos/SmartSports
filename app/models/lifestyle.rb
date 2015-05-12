class MyValidator < ActiveModel::Validator
  def validate(record)
    if (record.group == 'illness' && record.illness_type_id == nil)
      record.errors[:illness_type_id] << 'No value'
    elsif (record.group == 'pain' && record.pain_type_name == nil || record.pain_type_name == "")
      record.errors[:pain_type_name] << 'No value'
    end
  end
end

class Lifestyle < ActiveRecord::Base
  belongs_to :user
  belongs_to :illness_type
  validates :user_id, presence: true
  validates :group, presence: true
  validates :start_time, presence: true
  validates :amount, :numericality => true, :allow_nil => true
  validates_with MyValidator
end

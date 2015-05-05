class LabResult < ActiveRecord::Base
  belongs_to :user
  validates :user_id, :presence => true, :allow_nil => true
  validates :hba1c, :numericality => true, :allow_nil => true
  validates :ldl_chol, :numericality => true, :allow_nil => true
  validates :egfr_epi, :numericality => true, :allow_nil => true
end

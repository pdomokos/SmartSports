class MedicationType < ActiveRecord::Base
  has_many :medications
end
class CustomMedicationType < ActiveRecord::Base
  has_many :medications
end
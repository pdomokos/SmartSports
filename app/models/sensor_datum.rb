class SensorDatum < ActiveRecord::Base
  belongs_to :sensor_measurement
  has_many :sensor_segments, dependent: :destroy
end

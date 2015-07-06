class SensorMeasurement < ActiveRecord::Base
  belongs_to :user
  has_many :sensor_data, dependent: :destroy

  def has_cadence?
    return (!self.cr_data.nil? && self.cr_data!="") || (self.version=='2.0' && self.sensor_data.collect{|it| it.sensor_type=='BIKE'}.any?)
  end

  def has_heart?
    return (!self.hr_data.nil? && self.hr_data!="")|| (self.version=='2.0' && self.sensor_data.collect{|it| it.sensor_type=='HEART'}.any?)
  end

  def has_stride?
    return false
  end
end
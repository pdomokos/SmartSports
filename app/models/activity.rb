class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity_type
  validates :user_id, presence: true
  validates :activity_type_id, presence: true
  validates :steps, allow_blank: true, numericality: {only_integer: true}
  validates :duration, allow_blank: true, numericality: true

  @@intensities = ["Low", "Moderate", "High"]
  def title
    self.try(:activity_type).try(:name) || "Unknown sport"
  end

  def subtitle
    intensity = ""
    if self.intensity && self.intensity<=3
      index = self.intensity.to_i
      intensity = "intensity: #{@@intensities[index-1]}"
     end
    duration = ""
    if self.duration
      duration = "duration: #{self.duration} min"
    end
    return "#{intensity},  #{duration}"
  end

  def interval

  end
end

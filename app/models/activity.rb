require 'csv'

class DateTimeValidator < ActiveModel::Validator
  def validate(record)
    if record.end_time < record.start_time
      record.errors[:base] << (I18n.t :error_end_time_greater)
    end
  end
end

class Activity < ActiveRecord::Base
  belongs_to :user
  belongs_to :activity_type
  validates :user_id, presence: true
  validates :activity_type_id, presence: true
  validates :steps, allow_blank: true, numericality: {only_integer: true}
  validates :duration, allow_blank: true, numericality: true
  validates_with DateTimeValidator


  @@intensity_values = ["activity_intensity_low", "activity_intensity_moderate", "activity_intensity_high"]
  @@header_values = "header_values"

  def self.intensity_values
    @@intensity_values
  end

  def self.header_values
    @@header_values
  end

  def title
    self.try(:activity_type).try(:name) || (I18n.t :activity_unknown)
  end

  def subtitle
    intensity = ""
    if self.intensity && self.intensity<=3
      index = self.intensity.to_i
      intensity = "#{(I18n.t :intensity)}: #{@@intensity_values[index-1]}"
     end
    duration = ""
    if self.duration
      duration = "#{I18n.t :duration}: #{self.duration} #{I18n.t :minute_abbr}"
    end
    return "#{intensity},  #{duration}"
  end

  def interval

  end

  def self.to_csv(options={}, lang = '')
    CSV.generate(options) do |csv|
      if lang == "hu"
        csv << [((I18n.t @@header_values, :locale => :hu).split(','))[0], ((I18n.t @@header_values, :locale => :hu).split(','))[1], ((I18n.t @@header_values, :locale => :hu).split(','))[2], ((I18n.t @@header_values, :locale => :hu).split(','))[3], ((I18n.t @@header_values, :locale => :hu).split(','))[4]]
      elsif lang == "en"
        csv << [((I18n.t @@header_values, :locale => :en).split(','))[0], ((I18n.t @@header_values, :locale => :en).split(','))[1], ((I18n.t @@header_values, :locale => :en).split(','))[2], ((I18n.t @@header_values, :locale => :en).split(','))[3], ((I18n.t @@header_values, :locale => :en).split(','))[4]]
      end
      all.each do |activity|
        if activity.activity_type
          if lang != ''
            if lang == "hu"
              name = DB_HU_CONFIG['activities'][activity.activity_type.name]
            elsif lang == "en"
              name = DB_EN_CONFIG['activities'][activity.activity_type.name]
            end
          else
            name = activity.activity_type.name
          end
        end
        if activity.activity_type && activity.duration
          if lang == "hu"
            csv << [activity.start_time.strftime("%Y-%m-%d %H:%M"), name, (I18n.t @@intensity_values[activity.intensity.to_i], :locale => :hu), activity.duration, activity.calories]
          elsif lang == "en"
            csv << [activity.start_time.strftime("%Y-%m-%d %H:%M"), name, (I18n.t @@intensity_values[activity.intensity.to_i], :locale => :en), activity.duration, activity.calories]
          end
        end
      end
    end
  end

end

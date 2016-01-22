class CustomForm < ActiveRecord::Base
  belongs_to :user
  has_many :custom_form_elements, :dependent => :delete_all

  validates :form_name, presence: true

  def self.form_list
    ret = %w(
      activity_exercise
      activity_regular
      diet_drink
      diet_food
      diet_quick_calories
      diet_smoke
      measurement_blood_glucose
      measurement_blood_pressure
      measurement_waist
      measurement_weight
      labresult_egfrepi
      labresult_hba1c
      labresult_ketone
      labresult_ldlchol
      medication_drugs
      medication_insulin
      notification_date
      notification_visit
      lifestyle_illness
      lifestyle_pain
      lifestyle_period
      lifestyle_sleep
      lifestyle_stress
    )
    return ret
  end
  def self.form_params
    im = %w(
      bicycle40
      regular40
      drink40
      food40
      food40
      smoke40
      bloodglucose
      bloodpressure40
      abdominal40
      weight40
      kidney40
      test_tube40
      ketone40
      water40
      oral40
      insulin40
      regular40
      doctor_40
      illness40
      pain40
      period40
      sleep40
      stress40
    )
    st = %w(
      exerciseStyle
      exerciseStyle
      dietStyle
      dietStyle
      dietStyle
      dietStyle
      healthStyle
      healthStyle
      healthStyle
      healthStyle
      labresultStyle
      labresultStyle
      labresultStyle
      labresultStyle
      medicationStyle
      medicationStyle
      healthStyle
      labresultStyle
      wellbeingStyle
      wellbeingStyle
      wellbeingStyle
      wellbeingStyle
      wellbeingStyle
    )
    titles = %w(
      exercise
      regular_activity
      drink
      food
      quick_calories
      smoking
      blood_glucose
      blood_pressure
      waist_circumfence
      body_weight
      labresult_egfrepi
      labresult_hba1c
      labresult_ketone
      labresult_ldlchol
      drugs
      insulin
      time
      lab_results
      illness
      pain
      period
      sleep
      stress
    )
    ret = Hash[self.form_list.zip(im.zip(st, titles))]
    return ret
  end
  def self.icons
    ret = %w(img_add
      img_addForm
      img_bp
      img_bloodSugar
      img_calories
      img_cycling
      img_diet
      img_docsvisit
      img_drink
      img_egfr
      img_familyHistory
      img_food
      img_hba1c
      img_healthForm
      img_illness
      img_insulin
      img_ketone
      img_labResults
      img_ldlchol
      img_logout
      img_medication
      img_medicine
      img_menuMore
      img_myForms
      img_new
      img_notification
      img_pain
      img_period
      img_pulse
      img_regularactivity
      img_running
      img_saved
      img_select
      img_settings
      img_sleep
      img_smoke
      img_stress
      img_swiming
      img_visitType
      img_waist
      img_walking
      img_weight
      img_wellBeing)
    return ret
  end
end

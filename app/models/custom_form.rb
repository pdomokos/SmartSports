class CustomForm < ActiveRecord::Base
  belongs_to :user
  has_many :custom_form_elements

  validates :form_name, presence: true

  def self.images
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

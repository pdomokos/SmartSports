# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@custom_loaded = () ->
  console.log "custom loaded"

  initDiet()
  if typeof window.init_custom_forms =='function'
    init_custom_forms()

  formList = ["activity_exercise",
              "activity_regular",
              "diet_drink",
              "diet_food",
              "diet_quick_calories",
              "diet_smoke",
              "health_blood_glucose",
              "health_blood_pressure",
              "health_waist",
              "health_weight",
              "labresult_egfrepi",
              "labresult_hba1c",
              "labresult_ketone",
              "labresult_ldlchol",
              "medication_drugs",
              "medication_insulin",
              "notification_visit",
              "wellbeing_illness",
              "wellbeing_pain",
              "wellbeing_period",
              "wellbeing_sleep",
              "wellbeing_stress"]

  $("#input-element_type").autocomplete({
    minLength: 0,
    source: formList,
    select: (event, ui) ->
      formSelected = ui['item']['label']
      console.log formSelected
      $("#add-form-element>div.dataForm>div").addClass("hidden")
      $(".dataFormContainer."+formSelected+"_elem").removeClass("hidden")
  }).focus ->
    $(this).autocomplete("search")

  $(document).on("click", "#add-custom-form", (evt) ->
    console.log "add custom clicked"
    $("#dataform").removeClass("hidden")
    $("#iconform").addClass("hidden")
    $("#input-form_name").removeClass("formFail")
    $("i.formFailSign").addClass("hidden")
    $("#input-form_name").val("")

    for cl in $("#iconselect")[0].classList
      $("#iconselect").removeClass(cl)
    $("#iconselect").addClass('dataFormField')
    $("#iconselect").addClass('left')
    $("#iconselect").addClass('iconselect_img_myForms')
    $("#formicon").val("img_myForms")

    location.href = "#openModalAddCustomForm"
  )

  $(document).on("click", ".add-form-element", (evt) ->
    console.log "addfe called"
    formid = evt.target.getAttribute('data-formid')
    console.log formid
    userid = $("#current-user-id").val()
    $("#openModalAddCustomFormElement div.dataFormContainer>form").attr("action", "/users/"+userid+"/custom_forms/"+formid+"/custom_form_elements")
    location.href = "#openModalAddCustomFormElement"
  )

  $(document).on("click", "#closeModalAddCustomForm", (evt) ->
    location.href = "#close"
  )

  $("#iconselect").on("click",  (evt) ->
    console.log "iconselect clicked"
    $("#dataform").addClass("hidden")
    $("#iconform").removeClass("hidden")
  )

  $("#backToForm").on("click",  (evt) ->
    $("#dataform").removeClass("hidden")
    $("#iconform").addClass("hidden")
  )

  $("span.iconsel").on("click", (evt)->
    iconid = evt.target.id
    console.log iconid

    for cl in $("#iconselect")[0].classList
      $("#iconselect").removeClass(cl)

    $("#iconselect").addClass('dataFormField')
    $("#iconselect").addClass('left')
    $("#iconselect").addClass('iconselect_'+iconid)
    $("#formicon").val(iconid)

    $("#dataform").removeClass("hidden")
    $("#iconform").addClass("hidden")
  )

  $("form#custom-create-form").on("ajax:success", (e, data, status, xhr) ->
    console.log data
    if data['ok'] == true
      location.href = "customforms"
    else
      $("#input-form_name").addClass("formFail")
      $("i.formFailSign").removeClass("hidden")
  ).on("ajax:error", (e, xhr, status, error) ->
    $("#input-form_name").addClass("formFail")
    $("i.formFailSign").removeClass("hidden")
  )

  $(".delete-form-form").on("ajax:success", (e, data, status, xhr) ->
    console.log e.target
    location.href = 'customforms'
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log "delete failed"
    console.log e.target
  )

  $("#openModalAddCustomFormElement form.resource-create-form").on("ajax:success", (e, data, status, xhr) ->
    location.href = "customforms"
  )

@fixdate = (strdate) ->
  curr = moment()
  m = moment(strdate, "YYYY-MM-DD HH:mm")
  m.date(curr.date())
  m.month(curr.month())
  m.year(curr.year())
  return m.format(moment_fmt)
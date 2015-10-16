# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@custom_loaded = () ->
  console.log "custom loaded"

  initDiet()
  initExercise()
  initMeas()
  initLifestyle()

  if typeof window.init_custom_forms =='function'
    init_custom_forms()

  formList = ["activity_exercise",
              "activity_regular",
              "diet_drink",
              "diet_food",
              "diet_quick_calories",
              "diet_smoke",
              "measurement_blood_glucose",
              "measurement_blood_pressure",
              "measurement_waist",
              "measurement_weight",
              "labresult_egfrepi",
              "labresult_hba1c",
              "labresult_ketone",
              "labresult_ldlchol",
              "medication_drugs",
              "medication_insulin",
              "notification_visit",
              "lifestyle_illness",
              "lifestyle_pain",
              "lifestyle_period",
              "lifestyle_sleep",
              "lifestyle_stress"]

  $("#input-element_type").autocomplete({
    minLength: 0,
    source: formList,
    select: (event, ui) ->
      formSelected = ui['item']['label']
      console.log formSelected
      $("#openModalAddCustomFormElement .dataFormContainer").addClass("hidden")
      $("#openModalAddCustomFormElement .dataFormSeparator").addClass("hidden")
      $("#openModalAddCustomFormElement ."+formSelected+"_elem").removeClass("hidden")
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
    formid = evt.target.getAttribute('data-formid')
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

  succ_fn = (d, st, jq) ->
    console.log "AJAX done: "
    console.log d
    console.log st
    console.log jq
    console.log "^^^^^^^^^^^^^^^^^^^^^"
  err_fn =  (d, st, jq) ->
    console.log "AJAX fail"
    console.log d
    console.log st
    console.log jq
    console.log "^^^^^^^^^^^^^^^^^^^^^"

  $("button.addCustomButton").on("click", (e) ->
    btn = e.target
    console.log btn.dataset.cform
    form_ids =btn.dataset.elements.split(',')
    console.log form_ids
    reqs = []
    for i in form_ids
      f = $("form.cfe-"+i)
      reqs.push($.ajax({
        url: f[0].action,
        type: 'POST',
        data: f.serialize()
      }).done(succ_fn).fail(err_fn))
    $.when.apply(undefined, reqs).done( () ->
      console.log "ALL COMPLETE"
      location.href = "customforms"
    ).fail( () ->
      console.log "SOME FAILED"
    )
  )

@fixdate = (strdate) ->
  curr = moment()
  m = moment(strdate, "YYYY-MM-DD HH:mm")
  m.date(curr.date())
  m.month(curr.month())
  m.year(curr.year())
  return m.format(moment_fmt)
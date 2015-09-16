# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@custom_loaded = () ->
  console.log "custom loaded"

  initDiet()

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
      location.href = "#close"
    else
      $("#input-form_name").addClass("formFail")
      $("i.formFailSign").removeClass("hidden")
  ).on("ajax:error", (e, xhr, status, error) ->
    $("#input-form_name").addClass("formFail")
    $("i.formFailSign").removeClass("hidden")
  )
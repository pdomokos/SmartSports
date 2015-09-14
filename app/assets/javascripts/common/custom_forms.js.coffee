# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@custom_loaded = () ->
  console.log "custom loaded"



  $(document).on("click", "#add-custom-form", (evt) ->
    console.log "add custom clicked"
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

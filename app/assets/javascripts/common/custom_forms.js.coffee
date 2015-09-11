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
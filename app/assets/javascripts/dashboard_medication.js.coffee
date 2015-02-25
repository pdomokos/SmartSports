@register_medication_cbs = () ->
  self = this
  console.log "register_medication_cbs()"

  $("#medication-form-sel").click (event) ->
    self.reset_form_sel()

    $("#medication-form-div").removeClass("hidden")
    $("#medication-form-sel div.log-sign").removeClass("hidden-placed")
    $("#medication-form-sel").addClass("selected")
#    $("#act-message-item").addClass("hidden")
#    $("#act-message-failed").addClass("hidden")
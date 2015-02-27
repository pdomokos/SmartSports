@register_medication_cbs = () ->
  self = this
  console.log "register_medication_cbs()"

  $("#medication-form-sel").click (event) ->
    self.reset_form_sel()
    $("#medication-data").removeClass("hidden")
    $("#medication-form-sel div.log-sign").removeClass("hidden-placed")
    $("#medication-form-sel").addClass("selected")
#    $("#act-message-item").addClass("hidden")
#    $("#act-message-failed").addClass("hidden")

  ipanel = new InputPanel("medication-data", "medication")
  ipanel.validate_cb = (target, values) ->
    console.log values
    if !values['name'] and !values['amount']
      alert("Medication name and amount missing.")
      return false
    values[this.model_name+'[name]'] = values['name']
    values[this.model_name+'[amount]'] = values['amount']
    delete values['name']
    delete values['amount']
    return true
  ipanel.preproc_cb = (data) ->
    data.date = fmt_hm(new Date(Date.parse(data.date)))

  ipanel.start()
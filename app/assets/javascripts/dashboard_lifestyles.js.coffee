@register_lifestyle_cbs = () ->
  console.log "register_filestyle_cbs()"

  $("#lifestyle-form-sel").click (event) ->
    self.reset_form_sel()
    $("#lifestyle-data").removeClass("hidden")
    $("#lifestyle-form-sel div.log-sign").removeClass("hidden-placed")
    $("#lifestyle-form-sel").addClass("selected")
    $("#lifestyle-data").focus()

  ipanel = new InputPanel("lifestyle-data", "lifestyle")
  ipanel.validate_cb = (target, values) ->
    if "eat-event" in target.classList
      if !values['food'] and !values['calories']
        alert("Food name and calory missing.")
        return false
      values[this.model_name+'[group]'] = 'eat'
      values[this.model_name+'[name]'] = values['food']
      values[this.model_name+'[amount]'] = values['calories']
      delete values['food']
      delete values['calories']
      delete values['drink']
      delete values['cigarette']
    else if "drink-event" in target.classList
      values[this.model_name+'[group'] = 'drink'
      values[this.model_name+'[name'] = values['drink']
      delete values['food']
      delete values['drink']
      delete values['calories']
      delete values['cigarette']
    else if "cigarette-event" in target.classList
      values[this.model_name+'[group]'] = 'cigarette'
      values[this.model_name+'[amount]'] = values['cigarette']
      delete values['food']
      delete values['drink']
      delete values['calories']
      delete values['cigarette']
    return true
  ipanel.preproc_cb = (data) ->
    data.start_time = fmt_hm(new Date(Date.parse(data.start_time)))

  ipanel.start()
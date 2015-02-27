@register_activity_cbs = () ->
  console.log "register_activity_cbs()"

  $("#act-form-sel").click (event) ->
    self.reset_form_sel()
    $("#activity-data").removeClass("hidden")
    $("#act-form-sel div.log-sign").removeClass("hidden-placed")
    $("#act-form-sel").addClass("selected")
    $("#act-steps").focus()

    ipanel = new InputPanel("activity-data", "activity")
    ipanel.validate_cb = (target, values) ->
      console.log values
      if "walking-act" in target.classList
        if !values['duration'] and !values['steps'] and !values['distance']
          alert("Empty event can not be added.")
          return false
        values[this.model_name+'[group]'] = 'walking'
        values[this.model_name+'[steps]'] = values['steps']
        values[this.model_name+'[duration]'] = values['duration']
        values[this.model_name+'[distance]'] = values['distance']
        delete values['steps']
        delete values['duration']
        delete values['distance']
      else if "running-act" in target.classList
        if !values['duration'] and !values['steps'] and !values['distance']
          alert("Empty event can not be added.")
          return false
        values[this.model_name+'[group]'] = 'running'
        values[this.model_name+'[steps]'] = values['steps']
        values[this.model_name+'[duration]'] = values['duration']
        values[this.model_name+'[distance]'] = values['distance']
        delete values['steps']
        delete values['duration']
        delete values['distance']
      else if "cycling-act" in target.classList
        if !values['duration'] and !values['steps'] and !values['distance']
          alert("Empty event can not be added.")
          return false
        values[this.model_name+'[group]'] = 'cycling'
        values[this.model_name+'[duration]'] = values['duration']
        values[this.model_name+'[distance]'] = values['distance']
        delete values['duration']
        delete values['distance']
      return true
    ipanel.preproc_cb = (data) ->
      data.start_time = fmt_hm(new Date(Date.parse(data.start_time)))

    ipanel.start()
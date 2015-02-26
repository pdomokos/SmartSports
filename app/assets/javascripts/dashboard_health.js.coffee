@register_health_cbs = () ->
  self = this
  console.log "register_health_cbs()"

  $("#health-form-sel").click (event) ->
    self.reset_form_sel()
    $("#health-data").removeClass("hidden")
    $("#health-form-sel div.log-sign").removeClass("hidden-placed")
    $("#health-form-sel").addClass("selected")
    $("#meas-sys").focus()

  ipanel = new InputPanel("health-data", "measurement")
  ipanel.validate_cb = (target, values) ->
    if target.classList.contains("heart-meas")
      sys = $("#meas-sys").val()
      dia = $("#meas-dia").val()
      hr = $("#meas-hr").val()
      console.log "heart meas: "+sys+"/"+dia+"/"+hr
      if sys=="" and dia =="" and hr==""
        alert("Please specify heart measurements. e.g.: 122/87/70")
        return false
    if target.classList.contains("blood-meas")
      bs = $("#meas-blood_sugar").val()
      if bs==""
        alert("Please specify blood sugar measurement.")
        return false
    if target.classList.contains("body-meas")
      weight = $("#meas-weight").val()
      waist = $("#meas-waist").val()
      if weight=="" and waist==""
        alert("Please specify body measurements.")
        return false
    return true
  ipanel.validate_save_cb = (values) ->
    heart = values['heart']
    delete values['heart']
    if heart!="" and heart != "//"
      heart_arr = heart.split("/")
      if heart_arr.length !=3 or heart_arr[0]=="" or heart_arr[1]=="" or heart_arr[2]==""
        alert("Please specify the blood pressure in a SYS/DIA/PULSE format, e.g. 119/87/75")
        return false
      values['systolicbp'] = heart_arr[0]
      values['diastolicbp'] = heart_arr[1]
      values['pulse'] = heart_arr[2]
    return true
  ipanel.preproc_cb = (data) ->
    syst = data.systolicbp
    if syst == null
      syst = ""
    dia = data.diastolicbp
    if dia == null
      dia = ""
    hr = data.pulse
    if hr == null
      hr = ""

    if syst=="" and dia=="" and hr==""
      data.heart = ""
    else
      data.heart = syst + "/" + dia + "/" + hr

    data.date = fmt_hm(new Date(Date.parse(data.date)))

  ipanel.start()



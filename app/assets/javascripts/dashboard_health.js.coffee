@register_health_cbs = () ->
  self = this
  console.log "register_health_cbs()"

  $("#heart-form-sel").click (event) ->
    self.reset_form_sel()
    $("#health-form-div").removeClass("hidden")
    #    $("#meas-message").addClass("hidden-placed")
    $("#heart-form-sel div.log-sign").removeClass("hidden-placed")
    $("#heart-form-sel").addClass("selected")
    $("#meas-sys").focus()


  $("i.measurement-add").click (event) ->
    add_measurement_submit_handler(event)

  $("#meas-table").on("click", "div.edit-meas-control",
  (event) ->
    edit_measurement_submit_handler(event)
  )

  $("#manualdata-container").on("click", "div.delete-meas-control",
  (event) ->
    delete_measurement_submit_handler(event)
  )

  $("#manualdata-container").on("click", "div.save-meas-control",
  (event) ->
    save_measurement_submit_handler(event)
  )

  $("#meas-table").on("click", "div.cancel-meas-control",
  (event) ->
    cancel_measurement_submit_handler(event)
  )

  fill_recent_meas()

@fill_recent_meas = () ->
  current_user = $("#form-user-id")[0].value
  $("#meas-table .measure-item").remove()
  $.ajax '/users/' + current_user + '/measurements.json?source=smartsport&order=desc&limit=4',
    type: 'GET',
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "list measurement AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "list measurement  Successful AJAX call"
      for d in data
        new_row = $("#meas-row-template").children().first().clone()
        new_id = "meas-row-" + d.id
        new_row.attr('id', new_id)
        new_row.insertAfter($("#meas-table > div:last-of-type"))
        $("#" + new_id + " span.attr-date").html(fmt_hm(new Date(Date.parse(d.date))))
        $("#" + new_id + " input.attr-date").val(fmt_hm(new Date(Date.parse(d.date))))

        syst = d.systolicbp
        if syst == null
          syst = ""
        dia = d.diastolicbp
        if dia == null
          dia = ""
        hr = d.pulse
        if hr == null
          hr = ""
        if syst=="" and dia=="" and hr==""
          heart = ""
        else
          heart = syst + "/" + dia + "/" + hr
        $("#" + new_id + " span.attr-bp").html(heart)
        $("#" + new_id + " input.attr-bp").val(heart)

        $("#" + new_id + " span.attr-bloodsugar").html(d.blood_sugar)
        $("#" + new_id + " input.attr-bloodsugar").val(d.blood_sugar)

        $("#" + new_id + " span.attr-weight").html(d.weight)
        $("#" + new_id + " input.attr-weight").val(d.weight)

        $("#" + new_id + " span.attr-waist").html(d.waist)
        $("#" + new_id + " input.attr-waist").val(d.waist)

@add_measurement_submit_handler = (event) ->
  event.preventDefault()
  target = event.target

  if target.classList.contains("heart-meas")
    sys = $("#meas-sys").val()
    dia = $("#meas-dia").val()
    hr = $("#meas-hr").val()
    console.log "heart meas: "+sys+"/"+dia+"/"+hr
    if sys=="" and dia =="" and hr==""
      alert("Please specify heart measurements.")
      return
  if target.classList.contains("blood-meas")
    bs = $("#meas-blood_sugar").val()
    if bs==""
      alert("Please specify blood sugar measurement.")
      return
  if target.classList.contains("body-meas")
    weight = $("#meas-weight").val()
    waist = $("#meas-waist").val()
    if weight=="" and waist==""
      alert("Please specify body measurements.")
      return

  values = @create_values("heart-form")
  values["measurement[source]"] = "smartsport"
  console.log "HEART MEAS"

  current_user = $("#form-user-id")[0].value

  $("#meas-message").addClass("hidden-placed")
  console.log values
  $.ajax '/users/' + current_user + '/measurements',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE measurement AJAX Error: #{textStatus}"
      $("#meas-message").html("Failed to add measurement <i class=\"fa fa-exclamation-circle failure\"></i>")
      $("#meas-message").removeClass("hidden-placed")
    success: (data, textStatus, jqXHR) ->
      console.log "CREATE measurement  Successful AJAX call"
      console.log data
      console.log data.status
      if data.status == "OK"
        $("#meas-message").removeClass("hidden-placed")
        $("#meas-message-item").html("<i class=\"fa fa-check success\"></i><span>Added heart data</span><span class=\"edit-control-holder\"><div class=\"edit-meas-control\">Edit</div></span><span class=\"delete-control-holder\"><div class=\"delete-meas-control\">Delete</div></span>")
        $("#current-measurement-data").val(JSON.stringify(data.result))
        $("#heart-form input").val("")
        fill_recent_meas()

@set_m_param = (element_id, hash) ->
  key = element_id.split("-")[1]
  $("#" + element_id).val(hash[key])
  console.log "setting mparam " + "#" + element_id + "[" + key + "]=" + hash[key]

@add_m_param = (name, hash) ->
  pname = $("#" + name).attr("name")
  pname = 'measurement[' + pname + ']'
  pval = $("#" + name).val()
  hash[pname] = pval

@create_m_params = (parent) ->
  result = Object()
  #  @add_param("meas-user_id", result)
  #  @add_param("meas-source", result)
  for e in $("#" + parent + " input")
    console.log e.id
    @add_m_param(e.id, result)
  return result

@create_values = (parent_id) ->
  result = Object()
  for e in $("#"+parent_id+" input")
    name = e.name
    value = e.value
    result[name] = value
  return result

@save_measurement_submit_handler = (event) ->
  event.preventDefault()
  parent_id = event.target.parentNode.parentNode.id
  meas_id = parent_id.split("-")[-1..]
  console.log "save pressed " + parent_id + " " + meas_id
  values = create_values(parent_id)
  heart = values['heart']
  delete values['heart']
  if heart!="" and heart != "//"
    heart_arr = heart.split("/")
    if heart_arr.length !=3 or heart_arr[0]=="" or heart_arr[1]=="" or heart_arr[2]==""
      alert("Please specify the blood pressure in a SYS/DIA/PULSE format, e.g. 119/87/75")
      return
    values['systolicbp'] = heart_arr[0]
    values['diastolicbp'] = heart_arr[1]
    values['pulse'] = heart_arr[2]
  values_processed = Object()
  for k in Object.keys(values)
    values_processed['measurement['+k+']'] = values[k]
  console.log values_processed
  current_user = $("#current-user-id")[0].value

  $.ajax '/users/' + current_user + '/measurements/' + meas_id,
    type: 'PUT',
    data: values_processed,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "UPDATE measurement AJAX Error: #{textStatus}"
      $("#meas-message").html("Failed to update measurement <i class=\"fa fa-exclamation-circle failure\"></i>")
      $("#meas-message").removeClass("hidden-placed")
    success: (data, textStatus, jqXHR) ->
      console.log "UPDATE measurement  Successful AJAX call"
      console.log data
      if data.status == "OK"


        $("#" + parent_id + " span.list-edit").addClass("hidden")
        $("#" + parent_id + " span.list-attr").removeClass("hidden")
        $("#" + parent_id + " span.list-ctrl.show").removeClass("hidden")
        $("#" + parent_id + " span.list-ctrl.edit").addClass("hidden")
        fill_recent_meas()
      else
        $("#meas-message").html("Failed to update measurement <i class=\"fa fa-exclamation-circle failure\"></i>")
        $("#meas-message").removeClass("hidden-placed")


@edit_measurement_submit_handler = (event) ->
  event.preventDefault()
  console.log "edit pressed"
  rowid = event.target.parentNode.parentNode.id
  $("#" + rowid + " span.list-edit").removeClass("hidden")
  $("#" + rowid + " span.list-attr").addClass("hidden")
  $("#" + rowid + " span.list-ctrl.show").addClass("hidden")
  $("#" + rowid + " span.list-ctrl.edit").removeClass("hidden")

tmp = () ->
  $("#health-form-div #action-table").addClass("hidden")
  $("#manualdata-container #meas-message").addClass("hidden")
  data = $("#current-measurement-data").val()
  data = JSON.parse(data)
  console.log data
  $("#measurement-container div.measure-ui").removeClass("hidden")
  $("#measurement-container .edit-controls").removeClass("hidden")
  for e in $("form#heart-form input.measure-param")
    console.log e.id
    @set_m_param(e.id, data)

@delete_measurement_submit_handler = (event) ->
  event.preventDefault()
  id = event.target.parentNode.parentNode.id.split("-")[-1..]
  console.log "delete pressed id=" + id
  current_user = $("#current-user-id")[0].value
  console.log id
  $.ajax '/users/' + current_user + '/measurements/' + id,
    type: 'DELETE',
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "Destroy measurement AJAX Error: #{textStatus}"
      $("#meas-message").html("Failed to delete measurement <i class=\"fa fa-exclamation-circle failure\"></i>")
      $("#meas-message").removeClass("hidden-placed")
    success: (data, textStatus, jqXHR) ->
      console.log "Destroy measurement  Successful AJAX call"
      $("#meas-message-item").html("<i class=\"fa fa-check success\"></i><span>Deleted</span>")
      fill_recent_meas()

@cancel_measurement_submit_handler = (event) ->
  event.preventDefault()
  console.log "cancel pressed"
  rowid = event.target.parentNode.parentNode.id
  $("#" + rowid + " span.list-edit").addClass("hidden")
  $("#" + rowid + " span.list-attr").removeClass("hidden")
  $("#" + rowid + " span.list-ctrl.show").removeClass("hidden")
  $("#" + rowid + " span.list-ctrl.edit").addClass("hidden")


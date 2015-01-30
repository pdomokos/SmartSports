
@dashboard_loaded = (is_mobile=false) ->
  if not is_mobile
    @init_browser_dashboard()
  else
    @init_mobile_dashboard()

@init_browser_dashboard = () ->
  reset_ui()
  $("#dashboard-button").addClass("selected")
  console.log "dashboard loaded"
  @setdate()
  @update_summary(false)
  self = this

  @load_notifications()

  @register_activity_cbs()
  @register_lifestyle_cbs()

  $("#act-form-sel").click (event) ->
    reset_form_sel()
    $("#act-form-div").removeClass("hidden")
    $("#act-form-sel div.log-sign").removeClass("hidden-placed")
    $("#act-form-sel").addClass("selected")
    $("#act-message-item").addClass("hidden")
    $("#act-message-failed").addClass("hidden")
    $("#act-steps").focus()


  $("#heart-form-sel").click (event) ->
    reset_form_sel()
    $("#heart-form-div").removeClass("hidden")
    $("#meas-message").addClass("hidden-placed")
    $("#heart-form-sel div.log-sign").removeClass("hidden-placed")
    $("#heart-form-sel").addClass("selected")
    $("#meas-sys").focus()

  $("#friend-form-sel").click (event) ->
    reset_form_sel()
    $("#friend_name").val("")
    $("#friend-message").addClass("hidden-placed")
    $("#friend-form-div").removeClass("hidden")
    $("#friend-form-sel div.log-sign").removeClass("hidden-placed")
    $("#friend-form-sel").addClass("selected")
    $("#friend_name").focus()

  $("#save-activity-button").click (event) ->
    save_activity_handler(event)

  $("#cancel-activity-button").click (event) ->
    cancel_activity_handler(event)

  $("#save-measurement-button").click (event) ->
    save_measurement_submit_handler(event)

  $("#manualdata-container").on("click", "div.edit-meas-control",
    (event) ->
      edit_measurement_submit_handler(event)
  )

  $("#manualdata-container").on("click", "div.delete-meas-control",
    (event) ->
      delete_measurement_submit_handler(event)
  )

  $("#update-measurement-button").click (event) ->
    update_measurement_submit_handler(event)

  $("#cancel-measurement-button").click (event) ->
    cancel_measurement_submit_handler(event)

  $("#new-friend-button").click (event) ->
    new_friend_submit_handler(event)

@get_days_ago_ymd = (n) ->
  d = new Date()
  d.setDate(d.getDate()-n)
  return fmt(d)

new_friend_submit_handler = (event) ->
  event.preventDefault()
  values = $("#friend-form").serialize()
  console.log values
  $.ajax '/friendships',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (data, textStatus, errorThrown) ->
      console.log "CREATE friend AJAX Error: #{textStatus}"
      console.log data
    success: (data, textStatus, jqXHR) ->
      if data.status == "OK"
        console.log "CREATE friend  Successful AJAX call"
        console.log data
        $("#friend_name").val("")
        $("#friend-message").addClass("hidden-placed")
        load_notifications()
      else
        $("#friend-message").removeClass("hidden-placed")
#        $("#friend-form-div div.friend-message").addClass("red")
        msg = data.msg+" "+"<i class=\"fa fa-exclamation-circle failure\"></i>"
        $("#friend-message").html(msg)
        $("#")

@setdate = () ->
  now = new Date(Date.now())
  $(".logform input.date-input").val(fmt_hms(now))

reset_form_sel = () ->
  $("#act-form-div").addClass("hidden")
  $("#heart-form-div").addClass("hidden")
  $("#friend-form-div").addClass("hidden")
  $("#heart-form-sel div.log-sign").addClass("hidden-placed")
  $("#act-form-sel div.log-sign").addClass("hidden-placed")
  $("#friend-form-sel div.log-sign").addClass("hidden-placed")
  $("#heart-form-sel").removeClass("selected")
  $("#act-form-sel").removeClass("selected")
  $("#friend-form-sel").removeClass("selected")
  @setdate()

@add_param = (name, hash) ->
  pname = $("#"+name).attr("name")
  pval = $("#"+name).val()
  # duration is saved in seconds, but displayed in minutes
  if name[-8..] is "duration"
    orig = pval
    pval = Math.round(60.0*orig)
  hash[pname] = pval

@add_m_param = (name, hash) ->
  pname = $("#"+name).attr("name")
  pname = 'measurement['+pname+']'
  pval = $("#"+name).val()
  hash[pname] = pval

@create_params = (par) ->
  result = Object()
  @add_param("activity-form-userid", result)
  for e in $("form#act-form input."+par+"-param")
    console.log "create_params: "+e.id
    @add_param(e.id, result)
  return result

@create_m_params = () ->
  result = Object()
  @add_param("meas-user_id", result)
  @add_param("meas-source", result)
  for e in $("form#heart-form input.measure-param")
    console.log e.id
    @add_m_param(e.id, result)
  return result

@set_param = (element_id, hash) ->
  key = element_id.split("-")[1]
  if key[-4..] is "time"
    val = fmt_hms(new Date(hash[key]))
  else
    val = hash[key]
  # duration is saved in seconds, but displayed in minutes
  if key[-8..] is "duration"
    val = Math.round(hash[key]/60.0*100)/100.0

  $("#"+element_id).val(val)
  console.log "setting "+"#"+element_id+"["+key+"]="+val

@set_m_param = (element_id, hash) ->
  key = element_id.split("-")[1]
  $("#"+element_id).val(hash[key])
  console.log "setting mparam "+"#"+element_id+"["+key+"]="+hash[key]

@save_measurement_submit_handler = (event) ->
    event.preventDefault()
    values = $("#heart-form").serialize()
    current_user = $("#current-user-id")[0].value
    $("#meas-message").addClass("hidden-placed")
    console.log values
    $.ajax '/users/'+current_user+'/measurements',
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
          $("#meas-sys").val("")
          $("#meas-dia").val("")
          $("#meas-hr").val("")

@update_measurement_submit_handler = (event) ->
  event.preventDefault()
  values = create_m_params()
  console.log values
  $("#meas-message").addClass("hidden-placed")
  $("#meas-message-item").html("")
  current_user = $("#current-user-id")[0].value
  meas_id = values['measurement[id]']
  $.ajax '/users/'+current_user+'/measurements/'+meas_id,
    type: 'PUT',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "UPDATE measurement AJAX Error: #{textStatus}"
      $("#meas-message").html("Failed to update measurement <i class=\"fa fa-exclamation-circle failure\"></i>")
      $("#meas-message").removeClass("hidden-placed")
    success: (data, textStatus, jqXHR) ->
      console.log "UPDATE measurement  Successful AJAX call"
      console.log data
      if data.status == "OK"
        $("#measurement-container div.measure-ui").addClass("hidden")
        $("#measurement-container .edit-controls").addClass("hidden")
        $("#heart-form-div #action-table").removeClass("hidden")
        $("#manualdata-container #meas-message").removeClass("hidden")
        $("#meas-message").removeClass("hidden-placed")
        $("#meas-message-item").html("<i class=\"fa fa-check success\"></i><span>Updated heart data</span>")
        $("#current-measurement-data").val(JSON.stringify(data.result))


@edit_measurement_submit_handler = (event) ->
    event.preventDefault()
    console.log "edit pressed"
    $("#heart-form-div #action-table").addClass("hidden")
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
    console.log "delete pressed"
    data = $("#current-measurement-data").val()
    data = JSON.parse(data)
    id = data['id']
    current_user = $("#current-user-id")[0].value
    console.log id
    $.ajax '/users/'+current_user+'/measurements/'+id,
      type: 'DELETE',
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "Destroy measurement AJAX Error: #{textStatus}"
        $("#meas-message").html("Failed to delete measurement <i class=\"fa fa-exclamation-circle failure\"></i>")
        $("#meas-message").removeClass("hidden-placed")
      success: (data, textStatus, jqXHR) ->
        console.log "Destroy measurement  Successful AJAX call"
        $("#meas-message-item").html("<i class=\"fa fa-check success\"></i><span>Deleted</span>")
        console.log data
        console.log data.status

@cancel_measurement_submit_handler = (event) ->
  event.preventDefault()
  console.log "cancel pressed"
  $("#heart-form-div #action-table").removeClass("hidden")
  $("#manualdata-container #meas-message").removeClass("hidden")
  $("#measurement-container div.measure-ui").addClass("hidden")
  $("#measurement-container .edit-controls").addClass("hidden")



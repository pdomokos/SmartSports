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
    save_measurement_submit_handler(event)

  $("#meas-table").on("click", "div.edit-meas-control",
  (event) ->
    edit_measurement_submit_handler(event)
  )

  $("#manualdata-container").on("click", "div.delete-meas-control",
  (event) ->
    delete_measurement_submit_handler(event)
  )

  $("#update-measurement-button").click (event) ->
    update_measurement_submit_handler(event)

  $("#meas-table").on("click", "div.cancel-meas-control",
  (event) ->
    cancel_measurement_submit_handler(event)
  )

  fill_recent_meas()

@fill_recent_meas = () ->
  for i in [0..3]
    console.log i
    new_row = $("#meas-row-template").children().first().clone()
    new_id =  "meas-row-" + i
    new_row.attr('id', new_id)
    new_row.insertAfter($("#meas-table > div:last-of-type"))

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
        $("div.measure-item input").val("")

@update_measurement_submit_handler = (event) ->
  event.preventDefault()
  values = create_m_params()
  console.log values
  $("#meas-message").addClass("hidden-placed")
  $("#meas-message-item").html("")
  current_user = $("#current-user-id")[0].value
  meas_id = values['measurement[id]']
  delete values['measurement[id]']
  delete values['measurement[user_id]']
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
        $("#health-form-div #action-table").removeClass("hidden")
        $("#manualdata-container #meas-message").removeClass("hidden")
        $("#meas-message").removeClass("hidden-placed")
        $("#meas-message-item").html("<i class=\"fa fa-check success\"></i><span>Updated heart data</span>")
        $("#current-measurement-data").val(JSON.stringify(data.result))
        $("div.measure-item input").val("")
      else
        $("#meas-message").html("Failed to update measurement <i class=\"fa fa-exclamation-circle failure\"></i>")
        $("#meas-message").removeClass("hidden-placed")


@edit_measurement_submit_handler = (event) ->
  event.preventDefault()
  console.log "edit pressed"
  rowid = event.target.parentNode.parentNode.id
  $("#"+rowid+" span.list-edit").removeClass("hidden")
  $("#"+rowid+" span.list-attr").addClass("hidden")
  $("#"+rowid+" span.list-ctrl.show").addClass("hidden")
  $("#"+rowid+" span.list-ctrl.edit").removeClass("hidden")

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
  rowid = event.target.parentNode.parentNode.id
  $("#"+rowid+" span.list-edit").addClass("hidden")
  $("#"+rowid+" span.list-attr").removeClass("hidden")
  $("#"+rowid+" span.list-ctrl.show").removeClass("hidden")
  $("#"+rowid+" span.list-ctrl.edit").addClass("hidden")
#  $("#health-form-div #action-table").removeClass("hidden")
#  $("#manualdata-container #meas-message").removeClass("hidden")
#  $("#measurement-container div.measure-ui").addClass("hidden")
#  $("#measurement-container .edit-controls").addClass("hidden")

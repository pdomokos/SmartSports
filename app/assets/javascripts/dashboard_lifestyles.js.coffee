@register_lifestyle_cbs = () ->
  console.log "register_filestyle_cbs()"

  $("i.lifestyle-add").click (event) ->
    name =  event.target.id.split("-")[0]
    console.log name
    current_user = $("#current-user-id")[0].value

    result = Object()
    self.add_param("activity-form-userid", result)
    self.add_param("lifestyle-form-source", result)
    result["lifestyle[name]"] = name
    result["lifestyle[start_time]"] = fmt_hms(new Date())

    $.ajax '/users/'+current_user+'/lifestyles',
      type: 'POST',
      data: result,
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "CREATE lifestyle AJAX Error: #{textStatus}"
        $("#life-message-failed").html("Failed to add lifestyle <i class=\"fa fa-exclamation-circle failure\"></i>")
        $("#life-message-item").removeClass("hidden")
        console.log jqXHR
      success: (data, textStatus, jqXHR) ->
        console.log "CREATE lifestyle  Successful AJAX call"
        console.log data
        $("#life-message-item").removeClass("hidden")
        $("#life-message-item span:first-of-type").html("Added "+name+" filestyle event.")
        $("#current-lifestyle-data").val(JSON.stringify(data['result']))

  $("#life-message-item div.delete-control").click (event) ->
    delete_lifestyle_handler(event)

  $("#life-message-item div.edit-control").click (event) ->
    edit_lifestyle_submit_handler(event)

  $("#save-lifestyle-button").click (event) ->
    save_lifestyle_handler(event)

  $("#cancel-lifestyle-button").click (event) ->
    cancel_lifestyle_handler(event)

@delete_lifestyle_handler = (event) ->
  data = JSON.parse($("#current-lifestyle-data").val())
  console.log "deleting action "+data['id']
  console.log data
  current_user = $("#current-user-id")[0].value
  $.ajax '/users/'+current_user+'/lifestyles/'+data['id'],
    type: 'DELETE',
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "DELETE lifestyle AJAX Error: #{textStatus}"
      console.log jqXHR
    success: (data, textStatus, jqXHR) ->
      console.log "DELETE Successful AJAX call"
      $("#life-message-item").addClass("hidden")

@edit_lifestyle_submit_handler = (event) ->
  $("#action-table").addClass("hidden")
  $("#life-message-item").addClass("hidden")
  data = $("#current-lifestyle-data").val()
  data = JSON.parse(data)
  console.log data
  lifestyle_name = data['name']
  $("#activity-container div."+lifestyle_name+"-ui").removeClass("hidden")
  $("#activity-container div.life-edit-controls").removeClass("hidden")
  for e in $("form#act-form input."+lifestyle_name+"-param")
    @set_param(e.id, data)
  console.log("edit lifestyle cb done")

@cancel_lifestyle_handler = (event) ->
  console.log "cancel"
  data = $("#current-lifestyle-data").val()
  data = JSON.parse(data)
  lifestyle_type = data['name']
  $("#action-table").removeClass("hidden")
  $("#life-message-item").removeClass("hidden")
  $("#activity-container div."+lifestyle_type+"-ui").addClass("hidden")
  $("#activity-container div.life-edit-controls").addClass("hidden")

@save_lifestyle_handler = (event) ->
  console.log "save lifestyle"
  data = JSON.parse($("#current-lifestyle-data").val())
  console.log data
  current_lifestyle = data['name']
  values = create_params(current_lifestyle)
  console.log values
  $("#life-message-item").addClass("hidden")

  current_user = $("#current-user-id")[0].value
  lifestyle_id = values['lifestyle[id]']
  delete values['lifestyle[id]']
  values['lifestyle[source]'] = 'smartsport'
  $.ajax '/users/'+current_user+'/lifestyles/'+lifestyle_id,
    type: 'PUT',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE lifestyle AJAX Error: #{textStatus}"
      $("#life-message-failed").html("<i class=\"fa fa-exclamation-circle failure\"></i>Failed to update lifestyle")
      $("#life-message-failed").removeClass("hidden")
      console.log jqXHR
    success: (data, textStatus, jqXHR) ->
      console.log "CREATE lifestyle Successful AJAX call"
      console.log data
      $("#life-message-item").removeClass("hidden")
      lifestyle = data['name']
      $("#action-table").removeClass("hidden")
      $("#life-message-item").removeClass("hidden")
      name = data['result']['name']
      console.log "hiding #activity-container div."+name+"-ui"
      $("#activity-container div."+name+"-ui").addClass("hidden")
      $("#activity-container div.life-edit-controls").addClass("hidden")
      $("#current-lifestyle-data").val(JSON.stringify(data['result']))


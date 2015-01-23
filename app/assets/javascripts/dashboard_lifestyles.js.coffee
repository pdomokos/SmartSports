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
        $("#act-message-item").html("Failed to add lifestyle <i class=\"fa fa-exclamation-circle failure\"></i>")
        $("#act-message").removeClass("hidden-placed")
        console.log jqXHR
      success: (data, textStatus, jqXHR) ->
        console.log "CREATE lifestyle  Successful AJAX call"
        console.log data
        $("#act-message").removeClass("hidden-placed")
        $("#act-message").html("<div id=\"life-message-item\" class=\"action-item\"><i class=\"fa fa-check success\"></i><span>Added "+name+"</span><span class=\"edit-control-holder\"><div class=\"edit-control\">Edit</div></span><span class=\"delete-control-holder\"><div class=\"delete-control\">Delete</div></span></div>")
        $("#current-lifestyle-data").val(JSON.stringify(data['result']))

  $("#manualdata-container").on("click", "#life-message-item div.delete-control",
  (event) ->
    delete_lifestyle_handler(event)
  )
  $("#manualdata-container").on("click", "#life-message-item div.edit-control",
  (event) ->
    edit_lifestyle_submit_handler(event)
  )

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
      $("#manualdata-container div.act-message").addClass("hidden-placed")

@edit_lifestyle_submit_handler = (event) ->
  $("#action-table").addClass("hidden")
  $("#manualdata-container div.act-message").addClass("hidden-placed")
  data = $("#current-lifestyle-data").val()
  data = JSON.parse(data)
  console.log data
  lifestyle_name = data['name']
  $("div.activity-container div."+lifestyle_name+"-ui").removeClass("hidden")
  $("#edit-controls").removeClass("hidden")
  for e in $("form#act-form input."+lifestyle_name+"-param")
    @set_param(e.id, data)

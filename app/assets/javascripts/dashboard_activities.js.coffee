@register_activity_cbs = () ->
  console.log "register_activity_cbs()"

  del = (event) ->
    friend_name = event.target.parentElement.firstChild.textContent
    event.target.parentElement.remove()
    $("#pingpong-activity-participant").append(new Option(friend_name, friend_name))

  $("#act-form").on("click", "i.remove-pingpong-participant", del)

  $("#add-pingpong-participant").click (event) ->
    player_sel = [[], [[0,1]], [[0,1], [0, 2], [1,2]], [[[0, 1], [2, 3]], [[0,2], [1,3]], [[0, 3],[1, 2]]]]
    pname = $("#pingpong-activity-participant").val()

    if( pname != null and $("#pingpong-participants span").size() < 3)
      console.log pname
      $("<div><span>"+pname+"</span> <i class=\"fa fa-minus-square text-red remove-pingpong-participant\"></i></div>").appendTo("#pingpong-participants")

      player_arr = [$("#current-user-name").val()]
      for s in $("#pingpong-participants span")
        player_arr.push(s.innerHTML)
      console.log player_arr


      $("#pingpong-activity-participant option[value="+pname+"]").remove()
      npart = $("#pingpong-participants span").size()
      console.log npart
      $("#pingpong-games option").remove()
      $("#pingpong-games-container").removeClass("hidden")
      if npart == 1 or npart == 2
        for g in player_sel[npart]
          game_txt = player_arr[g[0]]+" : "+player_arr[g[1]]
          $("#pingpong-games").append(new Option(game_txt, game_txt))
      else if npart==3
        for g in player_sel[npart]
          game_txt = player_arr[g[0][0]]+" - "+player_arr[g[0][1]] + " : "+ player_arr[g[1][0]]+" - "+player_arr[g[1][1]]
          console.log game_txt
          $("#pingpong-games").append(new Option(game_txt, game_txt))

  $("i.timer-start").click (event) ->
    name =  event.target.id.split("-")[0]
    console.log name
    $("#"+name+"-timer-value").html("00:00")
    $("#"+name+"-timer-start").addClass("hidden")
    $("#"+name+"-timer-stop").removeClass("hidden")
    $("#"+name+"-timer-value").removeClass("hidden")
    $("#"+name+"-timer-started-at").val(new Date().getTime())

    $("#"+name+"-timer-running").val("true")
    timer_handler = () ->
      if $("#"+name+"-timer-running") and $("#"+name+"-timer-running").val()=="true"
        started = parseInt($("#"+name+"-timer-started-at").val())
        curr = new Date().getTime()
        diff = Math.floor((curr - started)/1000)
        hour = Math.floor(diff/60/60)
        diff = diff - hour*60*60
        minutes = Math.floor(diff/60)
        diff = diff - minutes*60
        seconds = diff
        elapsed = ("0"+minutes.toString()).substr(-2)+":"+("0"+seconds.toString()).substr(-2)
        if hour > 0
          elapsed = ("0"+hour.toString()).substr(-2)+":"+elapsed
        $("#"+name+"-timer-value").html(elapsed)
        setTimeout( timer_handler, 1000)
    setTimeout(timer_handler, 1000)

  $("div.stop-control").click (event) ->
    name =  event.target.parentNode.id.split("-")[0]
    console.log "stopping "+name
    $("#"+name+"-timer-value").html("00:00")
    $("#"+name+"-timer-start").removeClass("hidden")
    $("#"+name+"-timer-stop").addClass("hidden")
    $("#"+name+"-timer-value").addClass("hidden")
    $("#"+name+"-timer-stopped-at").val(new Date().getTime())
    $("#"+name+"-timer-running").val("false")

    date = fmt_hms(new Date(parseInt($("#"+name+"-timer-started-at").val())))
    duration = Math.floor((parseInt($("#"+name+"-timer-stopped-at").val())-parseInt($("#"+name+"-timer-started-at").val()))/(1000))
    console.log(duration)

    result = Object()
    self.add_param("activity-form-userid", result)
    self.add_param("activity-form-source", result)
    result["activity[activity]"] = name
    result["activity[group]"] = name
    result["activity[start_time]"] = date
    result["activity[duration]"] = duration

    console.log result
    $("#act-message").addClass("hidden-placed")
    current_user = $("#current-user-id")[0].value
    $.ajax '/users/'+current_user+'/activities',
      type: 'POST',
      data: result,
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "CREATE activity AJAX Error: #{textStatus}"
        $("#act-message-item").html("Failed to add activity <i class=\"fa fa-exclamation-circle failure\"></i>")
        $("#act-message").removeClass("hidden-placed")
        console.log "fails"
        console.log jqXHR
      success: (data, textStatus, jqXHR) ->
        console.log "CREATE activity  Successful AJAX call"
        console.log data
        $("#act-message").removeClass("hidden-placed")
        $("#act-message").html("<div id=\"act-message-item\"  class=\"action-item\"><i class=\"fa fa-check success\"></i><span>Added "+name+" activity</span><span class=\"edit-control-holder\"><div class=\"edit-control\">Edit</div></span><span class=\"delete-control-holder\"><div class=\"delete-control\">Delete</div></span></div>")
        $("#current-activity-data").val(JSON.stringify(data['result']))

  console.log "REGISTER!!!!!!!!!"
  $("#manualdata-container").on("click", "#act-message-item div.edit-control",
      (event) ->
        edit_activity_submit_handler(event)
      )

  $("#manualdata-container").on("click", "#act-message-item div.delete-control",
    (event) ->
      delete_activity_handler(event)
    )

  $("#save-activity-button").click (event) ->
    save_activity_handler(event)

  $("#cancel-activity-button").click (event) ->
    cancel_activity_handler(event)

@edit_activity_submit_handler = (event) ->
  $("#action-table").addClass("hidden")
  $("#manualdata-container div.act-message").addClass("hidden-placed")
  data = $("#current-activity-data").val()
  data = JSON.parse(data)
  console.log data
  activity_type = data['activity']
  $("div.activity-container div."+activity_type+"-ui").removeClass("hidden")
  $("#edit-controls").removeClass("hidden")
  for e in $("form#act-form input."+activity_type+"-param")
    @set_param(e.id, data)

@delete_activity_handler = (event) ->
  data = JSON.parse($("#current-activity-data").val())
  console.log "deleting action "+data['id']
  console.log data
  current_user = $("#current-user-id")[0].value
  $.ajax '/users/'+current_user+'/activities/'+data['id'],
    type: 'DELETE',
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "DELETE activity AJAX Error: #{textStatus}"
      console.log jqXHR
    success: (data, textStatus, jqXHR) ->
      console.log "DELETE Successful AJAX call"
      $("#manualdata-container div.act-message").addClass("hidden-placed")

@cancel_activity_handler = (event) ->
  console.log "cancel"
  data = $("#current-activity-data").val()
  data = JSON.parse(data)
  activity_type = data['activity']
  $("#action-table").removeClass("hidden")
  $("#manualdata-container div.act-message").removeClass("hidden-placed")
  $("div.activity-container div."+activity_type+"-ui").addClass("hidden")
  $("#edit-controls").addClass("hidden")

@save_activity_handler = (event) ->
  console.log "save"
  data = JSON.parse($("#current-activity-data").val())
  console.log data
  current_activity = data['activity']
  console.log "current activity = "+current_activity
  values = create_params(current_activity)
  console.log values
  $("#act-message").addClass("hidden-placed")
  $("#act-message-item").html("")
  current_user = $("#current-user-id")[0].value
  act_id = values['activity[id]']
  delete values['activity[id]']
  $.ajax '/users/'+current_user+'/activities/'+act_id,
    type: 'PUT',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE activity AJAX Error: #{textStatus}"
      $("#act-message-item").html("<i class=\"fa fa-exclamation-circle failure\"></i>Failed to update activity")
      $("#act-message").removeClass("hidden-placed")
      console.log jqXHR
    success: (data, textStatus, jqXHR) ->
      console.log "CREATE measurements  Successful AJAX call"
      console.log data
      $("#act-message").removeClass("hidden-placed")
      activity_type = data['result']['activity']
      $("#action-table").removeClass("hidden")
      $("#manualdata-container div.act-message").removeClass("hidden-placed")
      $("div.activity-container div."+activity_type+"-ui").addClass("hidden")
      $("#edit-controls").addClass("hidden")

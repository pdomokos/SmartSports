fmt = d3.time.format("%Y-%m-%d")
fmt_hms = d3.time.format("%Y-%m-%d %H:%M:%S")

@dashboard_loaded = () ->
  reset_ui()
  $("#dashboard-button").addClass("selected")
  console.log "dashboard loaded"
  setdate()
  load_notifications()


  $("#act-form-sel").click (event) ->
    reset_form_sel()
    $("#act-form-div").removeClass("hidden")
    $("#act-form-sel div.log-sign").removeClass("hidden-placed")
    $("#act-form-sel").addClass("selected")
    $("#act-message").addClass("hidden-placed")
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

  $("#new-activity-button").click (event) ->
    new_activity_submit_handler(event)

  $("#new-measurement-button").click (event) ->
    new_measurement_submit_handler(event)

  $("#new-friend-button").click (event) ->
    new_friend_submit_handler(event)


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

setdate = () ->
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
  setdate()

@new_activity_submit_handler = (event) ->
  event.preventDefault()
  values = $("#act-form").serialize()
  $("#act-message").addClass("hidden-placed")
  $("#act-message").html("")
  $.ajax '/activities',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE activity AJAX Error: #{textStatus}"
      $("#act-message").html("Failed to add activity <i class=\"fa fa-exclamation-circle failure\"></i>")
      $("#act-message").removeClass("hidden-placed")
      console.log "fails"
      console.log jqXHR
    success: (data, textStatus, jqXHR) ->
      console.log "CREATE measurements  Successful AJAX call"
      console.log data
      $("#act-message").removeClass("hidden-placed")
      $("#act-message").html("Added activity <i class=\"fa fa-check success\"></i>")

@new_measurement_submit_handler = (event) ->
  event.preventDefault()
  values = $("#heart-form").serialize()
  valuesArr = $("#heart-form").serializeArray()
  $("#meas-message").addClass("hidden-placed")
  console.log valuesArr
  $.ajax '/measurements',
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
      $("#meas-message").html("Measurement added <i class=\"fa fa-check success\"></i>")
      $("#meas-message").removeClass("hidden-placed")
      $("#meas-sys").val("")
      $("#meas-dia").val("")
      $("#meas-hr").val("")

load_notifications = () ->
  notification_limit = 20
  $.ajax '/users/'+$("#current-user-id")[0].value+'/notifications?limit='+notification_limit,
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call"

      i = 0
      $("div#event-list").empty()
      for notif in data
        console.log "notif = "+ JSON.stringify(notif)
        newactivity = $("#event-template").children().first().clone()
        newid =  "notif-" + i
        newactivity.attr('id', newid)
        if i == 0
          $("div#event-list").html(newactivity)
        else
          newactivity.insertAfter($("div#event-list").children().last())

        $("#"+newid+" i").addClass("fa-paper-plane-o")

        d = fmt(new Date(Date.parse(notif['date'])))

        $("#"+newid+" div div.event-time span").html(d)
        $("#"+newid+" div div.event-title").html(notif['title'])

        activate_link = ""
        if notif['notification_data']
          notif_data = JSON.parse(notif['notification_data'])

          if notif_data['notif_type'] == 'friendreq'
            friend_id = notif_data['friendshipid']
            linkid = newid+"_"+notif_data["friendship_id"]
            activate_link = " <a href='#' id='"+linkid+"'>Manage friends</a>"
            $("#"+newid+" div div.event-details span").html(notif['detail']+activate_link)
            $("#"+linkid).click (evt) ->
              evt.preventDefault()
              reset_form_sel()
              $("#friend-form-div").removeClass("hidden")
              $("#friend-form-sel div.log-sign").removeClass("hidden-placed")
              $("#friend-form-sel").addClass("selected")

        else
          $("#"+newid+" div div.event-details span").html(notif['detail'])

        i += 1


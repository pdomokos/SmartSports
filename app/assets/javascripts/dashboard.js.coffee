fmt = d3.time.format("%Y-%m-%d")
fmt_hms = d3.time.format("%Y-%m-%d %H:%M:%S")

@dashboard_loaded = () ->
  reset_ui()
  $("#dashboard-button").addClass("selected")
  console.log "dashboard loaded"
  setdate()
  load_notifications()

  $(document).on "click", "#act-form-sel", (event) ->
    reset_form_sel()
    $("#act-form-div").removeClass("hidden")
    $("#act-form-sel div.log-sign").removeClass("hidden-placed")
    $("#act-form-sel").addClass("selected")

  $(document).on "click", "#heart-form-sel", (event) ->
    reset_form_sel()
    $("#heart-form-div").removeClass("hidden")
    $("#heart-form-sel div.log-sign").removeClass("hidden-placed")
    $("#heart-form-sel").addClass("selected")

  $(document).on "click", "#friend-form-sel", (event) ->
    reset_form_sel()
    $("#friend-form-div").removeClass("hidden")
    $("#friend-form-sel div.log-sign").removeClass("hidden-placed")
    $("#friend-form-sel").addClass("selected")

  $("#new-activity-button").click (event) ->
    new_activity_submit_handler(event)

  $("#new-measurement-button").click (event) ->
    new_measurement_submit_handler(event)

  $("#new-friend-button").click (event) ->
    new_friend_submit_handler(event)

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
  values = $("#new-activity-form").serialize()
  $.ajax '/activities',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE activity AJAX Error: #{textStatus}"

    success: (data, textStatus, jqXHR) ->
      console.log "CREATE measurements  Successful AJAX call"
      console.log data

@new_measurement_submit_handler = (event) ->
  event.preventDefault()
  values = $("#heart-form").serialize()
  valuesArr = $("#heart-form").serializeArray()
  console.log valuesArr
  $.ajax '/measurements',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE measurement AJAX Error: #{textStatus}"

    success: (data, textStatus, jqXHR) ->
      console.log "CREATE measurement  Successful AJAX call"
      console.log data
      uid = $("#heart-form input[name='measurement[user_id]']").val()
      notif_data = {}
      console.log "uid="+uid
      notif_data["notification[title]"] =  "Measurement"
      notif_data["notification[detail]"] = "New measurement added. SYS: "+data['systolicbp']+" DIA: "+data['systolicbp']+" pulse: "+data['pulse']
      notif_data["notification[type]"] = "meas"
      notif_data["notification[date]"] = fmt_hms(new Date(Date.now()))
      $.ajax 'users/'+uid+'/notifications',
        type: 'POST',
        data: notif_data,
        dataType: 'json'
        error: (jqXHR, textStatus, errorThrown) ->
          console.log "CREATE notification AJAX Error: #{textStatus}"

        success: (data, textStatus, jqXHR) ->
          load_notifications()
          $("#heart-form fieldset input").val("")

new_friend_submit_handler = (evt) ->
  console.log "new friend"

load_notifications = () ->
  notification_limit = 20
  $.ajax '/users/'+$("#current_user_id")[0].value+'/notifications?limit='+notification_limit,
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call"

      i = 0
      $("div#event-list").empty()
      console.log data
      for notif in data
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
        $("#"+newid+" div div.event-details span").html(notif['detail'])
        i += 1


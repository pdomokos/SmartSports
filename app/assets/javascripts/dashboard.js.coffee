@dashboard_loaded = () ->
  reset_ui()
  $("#dashboard-button").addClass("selected")

  $("#new-activity-form-button").click (event) ->
  console.log 'started show activity'
  $("#measurement-form").addClass("hidden")
  $("#activity-form").removeClass("hidden")

  $("#new-measurement-form-button").click (event) ->
    console.log 'started show meas'
    $("#activity-form").addClass("hidden")
    $("#measurement-form").removeClass("hidden")

  $("#new-activity-button").click (event) ->
    new_activity_submit_handler(event)

  $("#new-measurement-button").click (event) ->
    new_measurement_submit_handler(event)

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
  values = $("#new-measurement-form").serialize()
  $.ajax '/measurements',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE activity AJAX Error: #{textStatus}"

    success: (data, textStatus, jqXHR) ->
      console.log "CREATE measurements  Successful AJAX call"
      console.log data

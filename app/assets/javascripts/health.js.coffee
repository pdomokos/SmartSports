@health_loaded = () ->
  reset_ui()

  $("#health-button").addClass("selected")
  uid = $("#current_user_id")[0].value
  console.log uid
  actions_url = "/users/" + uid + "/measurements.json"
  d3.json(actions_url, draw_charts)

draw_charts = (data) ->
  health_type1 = "heartrate"
  health_type2 = "bloodpressure"
  health_type3 = "spo2"
  bp_chart = new HealthChart("withings", health_type1, health_type2, health_type3, data)
  now = new Date(Date.now())
  bp_chart.draw(now)

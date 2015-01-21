@health_loaded = () ->
  reset_ui()

  $("#health-button").addClass("selected")
  uid = $("#shown-user-id")[0].value
  console.log "getting health data for user:"+uid
  actions_summary_url = "/users/" + uid + "/measurements.json?summary=true&hourly=true"
  d3.json(actions_summary_url, draw_trend)

  d = new Date()
  d.setDate(d.getDate()-28)
  day_2week = fmt(d)
  actions_lastweek_url = "/users/" + uid + "/measurements.json?start="+day_2week
  d3.json(actions_lastweek_url, draw_detail)

draw_trend = (data) ->
  heart_trend_chart = new HealthTrendChart("heart-trend", data,
    ["systolicbp", "pulse", "diastolicbp"],
    ["SYS", "DIA", "HR"],
    ["left", "left", "right"]
    ["colset4_0", "colset4_1", "colset4_2"],
    ["mmHg", "1/min"],
    false
    )
  heart_trend_chart.draw()

draw_detail = (data) ->

  bp_chart = new HealthChart("withings", "bloodpressure", data)
  now = new Date(Date.now())
  bp_chart.draw(now)

  heart_chart = new HealthTrendChart("heartrate", data,
    ["pulse", "SPO2"],
    ["HR", "SPO2"],
    ["left", "right"]
    ["colset6_1", "colset6_2"],
    ["1/m", "%"],
    false,
    4.0/7
  )
  heart_chart.draw()


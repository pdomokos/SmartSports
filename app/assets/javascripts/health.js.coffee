@health_loaded = () ->
  reset_ui()

  $("#health-button").addClass("selected")
  uid = $("#shown-user-id")[0].value
  console.log "getting health data for user:"+uid
  meas_summary_url = "/users/" + uid + "/measurements.json?summary=true"
  d3.json(meas_summary_url, draw_trend)

#  d = new Date()
#  d.setDate(d.getDate()-7)
#  day_2week = fmt(d)
  actions_lastweek_url = "/users/" + uid + "/measurements.json"
  d3.json(actions_lastweek_url, draw_detail)

draw_trend = (data) ->

  heart_trend_chart = new TrendChart("heart-trend", data,
    ["systolicbp", "pulse", "diastolicbp"],
    ["SYS", "HR", "DIA"],
    ["left", "left", "right"]
    ["colset4_0", "colset4_1", "colset4_2"],
    ["mmHg", "1/min"],
    false
    )
  heart_trend_chart.margin = {top: 20, right: 35, bottom: 20, left: 30}
  heart_trend_chart.draw()

draw_detail = (data) ->
  console.log data
  bp_chart = new HealthChart("withings", "bloodpressure", data)
  now = new Date(Date.now())
  bp_chart.draw(now)

  heart_chart = new TrendChart("heartrate", data,
    ["pulse", "SPO2"],
    ["HR", "SPO2"],
    ["left", "right"]
    ["colset6_1", "colset6_2"],
    ["1/minutes", "SPO2%"],
    false,
    4.0/7
  )
  heart_chart.margin = {top: 20, right: 40, bottom: 20, left: 30}
  heart_chart.tick_unit = d3.time.day
  heart_chart.ticks = 2
  heart_chart.draw()

  blood_chart = new TrendChart("bloodsugar", data,
    ["blood_sugar", "waist"],
    ["Bood Sugar", "Waist"],
    ["left", "right"]
    ["colset6_1", "colset6_2"],
    ["mmol/L", "cm"],
    false,
      4.0/7
  )
  blood_chart.margin = {top: 20, right: 40, bottom: 20, left: 50}
  blood_chart.tick_unit = d3.time.day
  blood_chart.ticks = 2
  blood_chart.draw()
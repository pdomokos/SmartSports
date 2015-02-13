@init_mobile_dashboard = () ->
  reset_ui()
  $("#dashboard-button").addClass("selected")
  @setdate()
  @update_summary(true)
  self = this

  console.log("mobile dashboard")
  uid = $("#shown-user-id")[0].value
  d3.json("/users/"+uid+"/summaries.json?start="+@get_days_ago_ymd(30), mobile_act_data_received)

  actions_summary_url = "/users/" + uid + "/measurements.json?summary=true&hourly=true&start="+@get_days_ago_ymd(30)
  d3.json(actions_summary_url, mobile_heart_data_received)

mobile_act_data_received = (jsondata) ->
  act_trend_chart = new TrainingTrendChart("activity-trend", jsondata,
    ["walking_duration", "running_duration", "cycling_duration", "transport_duration", "steps"],
    ["Walking", "Running", "Cycling", "Transport", "Steps"],
    ["left", "left", "left", "left", "right"],
    ["colset2_0", "colset2_1", "colset2_2", "colset2_3", "colset2_4"],
    ["min", "step"]
    true,
    0.7
  )
  act_trend_chart.preproc_cb = (data) ->
    keys = ["walking_duration", "running_duration", "cycling_duration", "transport_duration"]
    for d in data
      for k in keys
        d[k] = d[k]/60.0
  act_trend_chart.margin = {top: 20, right: 50, bottom: 20, left: 40}
  act_trend_chart.draw()

mobile_heart_data_received = (jsondata) ->
  heart_trend_chart = new HealthTrendChart("heart-trend", jsondata,
    ["systolicbp", "pulse", "diastolicbp"],
    ["SYS", "HR", "DIA"],
    ["left", "left", "right"]
    ["colset4_0", "colset4_1", "colset4_2"],
    ["mmHg", "1/min"],
    false,
    0.7
  )
  heart_trend_chart.margin = {top: 20, right: 35, bottom: 20, left: 40}
  heart_trend_chart.draw()


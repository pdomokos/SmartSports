@analytics_loaded = () ->
  self = this
  uid = $("#current-user-id")[0].value

  if $("#selected-user-id").length >0
    suid = $("#selected-user-id")[0].value
    if suid && suid != ''
      uid = suid

  $("div.appMenu button").removeClass("selected")
  $("#analytics-link").css
    background: "rgba(240, 108, 66, 0.3)"

  dateToShow = moment().format(moment_datefmt)
  self.timeline = new TimelinePlot(uid, "analysis_data", dateToShow, "Daily timeline", {period: "daily"})
  self.timeline.draw("div.timelineChart")

  $('#timeline_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    onSelectDate: (ct, input) ->
      console.log("timeline date selected")
      self.timeline.update(moment(ct).format(moment_datefmt))
      input.datetimepicker('hide')
    todayButton: true
  })

  d3.json("/users/"+uid+"/measurements.json?meas_type=blood_sugar", draw_bg_data)

  startDate = moment().subtract(6, 'months').format(moment_datefmt)
  meas_summary_url = "/users/" + uid + "/measurements.json?summary=true&start="+startDate
  d3.json(meas_summary_url, draw_health_trend)

  d3.json("/users/"+uid+"/summaries.json?bysource=true&start="+startDate, draw_patient_activity_data)


@draw_bg_data = (jsondata) ->
  console.log "bg_data_received "+jsondata.length
  bg_trend_chart = new BGChart("bg", jsondata, 1.0/8)
  bg_extent = bg_trend_chart.get_time_extent()
  higlight_extents = getExtentsMiddle(bg_extent)
  bg_trend_chart.draw()
  if jsondata && jsondata.size>0
    bg_trend_chart.add_highlight(higlight_extents[0], higlight_extents[1], "selA")
    bg_trend_chart.add_highlight(higlight_extents[1], higlight_extents[2], "selB")


@draw_health_trend = (data) ->
  heart_trend_chart = new TrendChart("heart-trend", data,
    ["systolicbp", "pulse", "diastolicbp"],
    ["SYS", "HR", "DIA"],
    ["left", "right", "left"]
    ["colset4_0", "colset4_1", "colset4_2"],
    ["mmHg", "1/min"],
    false
  )
  heart_trend_chart.margin = {top: 20, right: 45, bottom: 20, left: 30}
  heart_trend_chart.draw()

@draw_patient_activity_data = (jsondata) ->
  console.log "patient data"
  window.devdata = jsondata
  Object.keys(jsondata).forEach( (src)->
    dev_chart = $("#device-data-template").children().first().clone()
    $(dev_chart).find("div.training-type").html(capitalize(src))
    $("#analytics-container").append(dev_chart)
  )
@draw_trends = (jsondata) ->
  act_trend_chart = new TrainingTrendChart("activity-trend", jsondata,
    ["steps", "running_duration", "cycling_duration"],
    ["Steps"," Running", "Cycling", ],
    ["right", "left", "left"],
    ["colset7_5", "colset2_0", "colset2_2"],
    ["minutes", "steps"]
    true
  )
  act_trend_chart.preproc_cb = (data) ->
    keys = ["walking_duration", "running_duration", "cycling_duration"]
    for d in data
      for k in keys
        d[k] = d[k]/60.0
  act_trend_chart.margin = {top: 20, right: 50, bottom: 20, left: 35}
  act_trend_chart.draw()


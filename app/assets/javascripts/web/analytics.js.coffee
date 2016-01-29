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

  d3.json("/users/"+uid+"/measurements.json?meas_type=blood_sugar", bg_data_received)
  meas_summary_url = "/users/" + uid + "/measurements.json?summary=true"
  d3.json(meas_summary_url, draw_health_trend)

  d3.json("/users/"+uid+"/summaries.json", patient_act_data_received)

  console.log "getting health data for user:"+uid
  meas_summary_url = "/users/" + uid + "/measurements.json?summary=true"
  d3.json(meas_summary_url, draw_health_trend)

@bg_data_received = (jsondata) ->
  console.log "bg_data_received "+jsondata.length
  bg_trend_chart = new BGChart("bg", jsondata, 1.0/8)
  bg_extent = bg_trend_chart.get_time_extent()
  higlight_extents = getExtentsMiddle(bg_extent)
  bg_trend_chart.draw()
  if jsondata && jsondata.size>0
    bg_trend_chart.add_highlight(higlight_extents[0], higlight_extents[1], "selA")
    bg_trend_chart.add_highlight(higlight_extents[1], higlight_extents[2], "selB")

@act_data_received = (jsondata) ->
  draw_trends(jsondata)
  @explore_data = jsondata
  #@draw_pie(get_yesterday_ymd())

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


@draw_pie = (day_ymd) ->
  pie_data = get_daily_data(day_ymd, @explore_data)
  pie_data_weekly = get_weekly_data(day_ymd, @explore_data)
  daily_piechart = new PieChart("daily-piechart", pie_data, pie_data_weekly)
  $("#daily-piechart-container span.pie1-label").html(day_ymd)
  $("#daily-piechart-container span.pie2-label").html(fmt(get_monday(day_ymd))+" : "+fmt(get_sunday(day_ymd)))
  daily_piechart.draw()

get_daily_data = (day_ymd, act) ->
  keys = Object.keys(act)
  daily = []
  for k in keys
    today_acts = act[k].filter( (d) -> fmt(new Date(Date.parse(d['date'])))==day_ymd )
    if today_acts.length>0
      if k=='walking'
        w = today_acts.filter( (d) -> d.source == 'withings')
        if w.length>0
          daily.push(w[0])
        else
          daily.push(today_acts[0])
      else
        daily.push(today_acts[0])
  console.log daily
  if daily.length == 0
    return daily
  pie_data = daily.map( (d) -> [d.group, d.total_duration/60.0])

  minutes = (pie_data.map( (d) -> d[1])).reduce( (a, b) -> a+b)
  pie_data.push(["other", (24.0*60-minutes)])
  return pie_data

get_weekly_data = (day_ymd, act) ->
  activity_keys = Object.keys(act)
  mon = get_monday(day_ymd)
  sun = get_sunday(day_ymd)
  now = new Date()
  if now < sun
    sun = now

  console.log "MON="+mon
  console.log "SUN="+sun
  console.log "WEEKLY"

  pie_data = []
  for k in activity_keys
    week_hash = Object()
    week_acts = act[k].filter( (d) -> (new Date(Date.parse(d['date']))>=mon) and (new Date(Date.parse(d['date']))<=sun) )

    if week_acts.length == 0
      continue

    for w in week_acts
      wkey = fmt(new Date(Date.parse(w['date'])))
      if week_hash[wkey]
        week_hash[wkey].push(w)
      else
        week_hash[wkey] = [w]

    dkeys = Object.keys(week_hash)

    weekly = []
    for dk in dkeys
      day_acts = week_hash[dk]
      if day_acts.length>0
        if k=='walking'
          w = day_acts.filter( (d) -> d.source == 'withings')
          if w.length>0
            weekly.push(w[0])
          else
            weekly.push(day_acts[0])
        else
          weekly.push(day_acts[0])

    total = weekly.map( (d) ->  d.total_duration/60.0 ).reduce( (a, b) -> a+b)
    pie_data.push([k, total])

  if pie_data.length==0
    return pie_data
  minutes = (pie_data.map( (d) -> d[1])).reduce( (a, b) -> a+b)
  total = (sun-mon)/1000/60
  pie_data.push(["other", (total-minutes)])
  return pie_data

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


@draw_blood_sugar = (data) ->

  blood_chart = new TrendChart("bloodsugar", data,
    ["blood_sugar", "waist"],
    ["Blood Glucose", "Waist"],
    ["left", "right"]
    ["colset6_1", "colset6_2"],
    ["mmol/L", "cm"],
    false
  )
  blood_chart.margin = {top: 20, right: 30, bottom: 20, left: 45}
  blood_chart.tick_unit = d3.time.day
  blood_chart.ticks = 4
  blood_chart.draw()
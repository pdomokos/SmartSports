@wellbeing_loaded = () ->
  uid = $("#current-user-id")[0].value
  d3.json("/users/"+uid+"/summaries.json", @data_received)

@data_received = (jsondata) ->
  @explore_data = jsondata
  @draw_trends()
  @draw_pie("2015-02-05")

@draw_trends = () ->
  console.log @explore_data

  self = this
  act_trend_chart = new TrendChart("explore-trend", @explore_data,
    ["walking_duration", "sleep_duration", "transport_duration"],
    ["Walking", "Sleep", "Transport"],
    ["left", "left", "left"],
    ["walking", "sleep", "transport" ],
    ["minutes"]
    false
  )

  act_trend_chart.get_series = () ->
    self=this
    template = {'date': null, 'walking_duration': 0, 'transport_duration': 0, 'sleep_duration': null}
    result = Object()
    for actkey in ['walking', 'sleep', 'transport']
      daily_activity = Object()
      if this.data[actkey]
        for d in this.data[actkey]
          key = fmt(new Date(Date.parse(d.date)))
          if daily_activity[key]
            daily_activity[key].push(d)
          else
            daily_activity[key] = [d]

      days = Object.keys(daily_activity)
      if days == null
        continue
      days.sort()

      for day in days
        daily_data = daily_activity[day]
        result_daily = result[day]
        if !result_daily
          result_daily = $.extend({}, template)
          result_daily['date'] = day
          result[day] = result_daily
        this.aggregate(daily_data, result_daily)

    days = Object.keys(result)
    days.sort()
    res = []
    for day in days
      res.push(result[day])
    return(res)

  act_trend_chart.aggregate = (data, result) ->
    len = data.length
    current_items = data.filter( (d) -> d['group'] == 'walking')
    if current_items.length != 0
      result['walking_duration'] = current_items[0]['total_duration']

    current_items = data.filter( (d) -> d['group'] == 'transport')

    if current_items.length != 0
      result['transport_duration'] = current_items[0]['total_duration']

    current_items =  data.filter( (d) -> d['source'] == 'fitbit')
    if current_items.length != 0
      walk_times = current_items.filter( (d) -> d['group'] == 'walking')
      if walk_times.length != 0
        result['walking_duration'] = current_items[0]['total_duration']

    current_items =  data.filter( (d) -> d['source'] == 'withings')
    if current_items.length != 0
      sleep_times = current_items.filter( (d) -> d['group'] == 'sleep')
      if sleep_times.length != 0
        result['sleep_duration'] = sleep_times[0]['total_duration']
      else
        result['sleep_duration'] = null

      walk_times = current_items.filter( (d) -> d['group'] == 'walking')
      if walk_times.length != 0
        result['walking_duration'] = walk_times[0]['total_duration']

  act_trend_chart.preproc_cb = (data) ->
    keys = ["walking_duration", "sleep_duration", "transport_duration"]
    for d in data
      for k in keys
        if d[k] != null
          d[k] = d[k]/60.0
  act_trend_chart.margin = {top: 20, right: 30, bottom: 20, left: 35}
  get_duration = (val_min) ->
    if val_min<60
      result = val_min.toFixed(1)+" minutes"
    else
      result = (val_min/60.0).toFixed(1)+" hours"
  act_trend_chart.cb_over = (d, node) ->
    node = d3.select(node)
    date_with_day = fmt_day(new Date(Date.parse(d.date)))
    if node.classed("walking")
      txt = date_with_day+" Walking: "+get_duration(d.walking_duration)
    else if node.classed("transport")
      txt = date_with_day+" Transport: "+get_duration(d.transport_duration)
    else if node.classed("sleep")
      txt = date_with_day+" Sleep: "+get_duration(d.sleep_duration)
    else
      txt = d.date
    $("#explore-trend-container div.notes").html(txt)

  act_trend_chart.cb_out = (d, node) ->
    $("#explore-trend-container div.notes").html("")

  act_trend_chart.cb_click = (d, node) ->
    draw_pie(d.date, self.explore_data)
  act_trend_chart.base_r = 4
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

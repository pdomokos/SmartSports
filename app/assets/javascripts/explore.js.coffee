@explore_loaded = () ->
  reset_ui()
  $("#explore-button").addClass("selected")
  uid = $("#shown-user-id")[0].value
  d3.json("/users/"+uid+"/summaries.json", data_received)

data_received = (jsondata) ->
  draw_trends(jsondata)
  draw_pie("2015-02-05", jsondata)

draw_trends = (jsondata) ->
  act_trend_chart = new TrendChart("explore-trend", jsondata,
    ["walking_duration", "sleep_duration", "transport_duration"],
    ["Walking", "Sleep", "Transport"],
    ["left", "left", "left"],
    ["walking", "sleep", "transport" ],
    ["minutes"]
    false
  )
  console.log jsondata
  act_trend_chart.get_series = () ->
    self=this
    template = {'date': null, 'walking_duration': 0, 'transport_duration': 0, 'sleep_duration': null}
    result = Object()
#    console.log(this.data)
    for actkey in ['walking', 'sleep', 'transport']
      daily_activity = Object()
      if this.data['activities'][actkey]
        for d in this.data['activities'][actkey]
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

#    console.log(result)
    return(result)

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
  act_trend_chart.margin = {top: 20, right: 10, bottom: 20, left: 35}

  act_trend_chart.cb_over = (d, node) ->
    console.log d
    node = d3.select(node)
    console.log node
    if node.classed("walking")
      txt = d.date+" walking: "+d.walking_duration
    else if node.classed("transport")
      txt = d.date+" walking: "+d.transport_duration
    else if node.classed("sleep")
      txt = d.date+" sleep: "+d.sleep_duration
    else
      txt = d.date
    $("#explore-trend-container div.notes").html(txt)

  act_trend_chart.cb_out = (d, node) ->

    $("#explore-trend-container div.notes").html("")
  act_trend_chart.cb_click = (d, node) ->
    console.log "click"
    console.log node

  act_trend_chart.draw()

draw_pie = (day_ymd, jsondata) ->
  pie_data = get_daily_data(day_ymd, jsondata['activities'])
  pie_data_weekly = get_weekly_data(day_ymd, jsondata['activities'])
  daily_piechart = new PieChart("daily-piechart", pie_data, pie_data_weekly)
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

  minutes = (pie_data.map( (d) -> d[1])).reduce( (a, b) -> a+b)
  total = (sun-mon)/1000/60
  pie_data.push(["other", (total-minutes)])
  return pie_data

@explore_loaded = () ->
  reset_ui()
  $("#explore-button").addClass("selected")
  uid = $("#shown-user-id")[0].value
  d3.json("/users/"+uid+"/summaries.json", data_received)

data_received = (jsondata) ->
  draw_trends(jsondata)

draw_trends = (jsondata) ->
  act_trend_chart = new TrendChart("explore-trend", jsondata,
    ["walking_duration", "sleep_duration", "transport_duration"],
    ["Walking", "Sleep", "Transport"],
    ["left", "left", "left"],
    ["colset5_6", "colset6_6", "colset6_1" ],
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

  act_trend_chart.draw()

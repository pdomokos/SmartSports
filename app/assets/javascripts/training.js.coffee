
#= require ActivityChart
#= require OverviewChart

@training_loaded = () ->
  reset_ui()
  register_events()

  $("#training-button").addClass("selected")
  uid = $("#shown-user-id")[0].value

  d3.json("/users/"+uid+"/activities.json", data_received)

data_received = (jsondata) ->
  draw_trends(jsondata)
  draw_conn(jsondata)

draw_trends = (jsondata) ->
#  console.log jsondata
  map = {}
  data = []
  template = {'date': null, 'walking_duration': 0, 'running_duration': 0, 'cycling_duration': 0, 'transport_duration': 0, 'sleep_duration': 0, 'steps': 0}
  for actkey in ['walking', 'running', 'cycling', 'transport']
    for d in jsondata['activities'][actkey]

      key = fmt(new Date(d.date))
      curr = map[key]
      if !curr
        map[key] = $.extend({}, template)
        curr = map[key]

      curr['date'] = key
      if d.source == 'moves'

        curr[actkey+'_duration'] = d.total_duration
        curr['steps'] = curr['steps']+d.steps

      keys = Object.keys(map)
      keys.sort()

      for k in keys
        data.push(map[k])

  act_trend_chart = new TrendChart("moves", "activity-trend", data,
    ["walking_duration", "running_duration", "cycling_duration", "transport_duration", "steps"],
    ["Walking", "Running", "Cycling", "Transport", "Steps"],
    ["left", "left", "left", "left", "right"],
    ["colset2_0", "colset2_1", "colset2_2", "colset2_3", "colset2_4"],
    ["min", "step"]
    true
  )
  act_trend_chart.preproc_cb = (data) ->
    console.log "CB called"
    keys = ["walking_duration", "running_duration", "cycling_duration", "transport_duration"]
    for k in keys
      for d in data[k]
        d['value'] = d['value']/60.0
  act_trend_chart.margin = {top: 20, right: 40, bottom: 20, left: 30}
  act_trend_chart.draw()


@trend_charts = []
@activity_charts = []
self = this

get_conn_data = (data, sourcename) ->
  keys = Object.keys(data.activities)
  result = {'source': sourcename, 'activities': {}}
  for k in keys
    result['activities'][k] = []
  for k in keys
    for d in data['activities'][k]
      if d.source == sourcename
        result['activities'][k].push( d )
  return(result)
  
draw_conn = (jsondata) ->
  for elem in $("#training-container div.connection-block")
    conn =  $("#"+elem.id+" input.connection-name")[0].value
    draw_conn_data(get_conn_data(jsondata, conn))

draw_conn_data = (jsondata) ->
  source = jsondata.source
  console.log "DOING "+source
  console.log jsondata
  jsondata = jsondata.activities
  data_helper = new DataHelper(jsondata)
  datanum = data_helper.get_data_size()
  if datanum==0
    console.log "No data"
    return
  data_helper.proc_training_data()

  d = new Date(Date.now())

  activity_chart = new ActivityChart(source, source+"-container", jsondata, data_helper)
  @activity_charts.push(activity_chart)
  activity_chart.update_daily(fmt(d))
  activity_chart.draw(d, "walking")
  activity_chart.set_callback(selection_callback)

  trend_chart = new OverviewChart(source, source+"-container", jsondata, data_helper)
  trend_chart.draw(d, "walking")
  @trend_charts.push(trend_chart)

  activity_chart.show_selection()
  trend_chart.show_curr_week(d)

selection_callback = (d) ->
  console.log "selection_callback called, "+d.source
  trend_chart = get_chart(self.trend_charts, d.source)
  trend_chart.show_curr_week(new Date(Date.parse(d.date)))

is_weekly = (par) ->
  return ($(par).find("input.is-weekly")[0].value == "yes")

get_curr_date = (par) ->
  return (new Date(Date.parse($(par).find("input.curr-date")[0].value)))

get_current_meas = (par) ->
  return ($(par).find("input.curr-meas")[0].value)

set_current_meas = (par, meas) ->
  $(par).find("input.curr-meas")[0].value = meas

get_chart = (charts, sel) ->
  for c in charts
    if c.connection == sel
      return c

register_events = () ->
  $("i.activities-left-arrow").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    chart = get_chart(self.activity_charts, activity_conn)
    if is_weekly(par)
      curr = get_curr_date(par)
      date = curr.getDate()
      curr.setDate(date-7)
      chart.update_weekly(fmt(curr))
      $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
      chart.draw(curr, get_current_meas(par))
    else
      curr = get_curr_date(par)
      curr.setDate(curr.getDate()-1)
      chart.update_daily(fmt(curr))
      $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
      chart.draw(curr, get_current_meas(par))
    chart.show_selection()
    trend_chart = get_chart(self.trend_charts, activity_conn)
    trend_chart.show_curr_week(curr)

  $("i.activities-right-arrow").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    chart = get_chart(self.activity_charts, activity_conn)
    if is_weekly(par)
      curr = get_curr_date(par)
      date = curr.getDate()
      curr.setDate(date+7)
      chart.update_weekly(fmt(curr))
      $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
      chart.draw(curr, get_current_meas(par))
    else
      curr = get_curr_date(par)
      curr.setDate(curr.getDate()+1)
      chart.update_daily(fmt(curr))
      $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
      chart.draw(curr, get_current_meas(par))
    chart.show_selection()
    trend_chart = get_chart(self.trend_charts, activity_conn)
    trend_chart.show_curr_week(curr)

  $("span.today-button").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    chart = get_chart(self.activity_charts, activity_conn)
    $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
    today = new Date(Date.now())
    chart.update_daily(fmt(today))
    chart.draw(today, get_current_meas(par))
    chart.show_selection()
    trend_chart = get_chart(self.trend_charts, activity_conn)
    currdate = get_curr_date(par)
    trend_chart.show_curr_week(currdate)

  $("span.week-button").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    chart = get_chart(self.activity_charts, activity_conn)
    currdate = get_curr_date(par)
    chart.update_weekly(currdate)

  $("div.steps").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    set_selected(evt)
    set_current_meas(par, "walking")
    curr = get_curr_date(par)
    $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
    $("#"+activity_conn+"-container svg.activity-trend-svg").empty()
    chart = get_chart(self.activity_charts, activity_conn)
    chart.draw(curr, get_current_meas(par))
    trend_chart = get_chart(self.trend_charts, activity_conn)
    trend_chart.draw(curr, get_current_meas(par))

  $("div.km-running").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    set_selected(evt)
    set_current_meas(par, "running")
    curr = get_curr_date(par)
    $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
    $("#"+activity_conn+"-container svg.activity-trend-svg").empty()
    chart = get_chart(self.activity_charts, activity_conn)
    chart.draw(curr, get_current_meas(par))
    trend_chart = get_chart(self.trend_charts, activity_conn)
    trend_chart.draw(curr, get_current_meas(par))

  $("div.km-cycling").click (evt) ->
    par = evt.currentTarget.parentNode.parentNode.parentNode.parentNode
    activity_conn =  $(par).find("input.connection-name")[0].value
    set_selected(evt)
    set_current_meas(par, "cycling")
    curr = get_curr_date(par)
    $("#"+activity_conn+"-container svg.activity-chart-svg").empty()
    $("#"+activity_conn+"-container svg.activity-trend-svg").empty()
    chart = get_chart(self.activity_charts, activity_conn)
    chart.draw(curr, get_current_meas(par))
    trend_chart = get_chart(self.trend_charts, activity_conn)
    trend_chart.draw(curr, get_current_meas(par))

set_selected = (evt) ->
  clicked_block = evt.toElement.parentNode
  $("div.meas-block").removeClass("selected")
  clicked_block.classList.add("selected")

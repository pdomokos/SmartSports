
#= require ActivityChart
#= require TrendChart

@training_loaded = () ->
  reset_ui()
  register_events()

  $("#training-button").addClass("selected")
  uid = $("#current_user_id")[0].value

  for elem in $("#training-container div.connection-block")
    console.log elem.id
    conn =  $("#"+elem.id+" input.connection-name")[0].value
    actions_url = "/users/"+uid+"/activities.json?source="+conn
    d3.json(actions_url, data_received)

fmt = d3.time.format("%Y-%m-%d")
fmt_words = d3.time.format("%Y %b %e")

#time_extent = []
time_scale = []
trend_time_scale = []
trend_time_extent = []
height = 0
trend_height = 0

data_helper = null
trend_chart = null
activity_chart = null

data_received = (jsondata) ->
  source = jsondata.source
  console.log "DATA_RECEIVED "+source
  jsondata = jsondata.activities
  console.log jsondata
  data_helper = new DataHelper(jsondata)
  datanum = data_helper.get_data_size()
  if datanum==0
    console.log "No data"
    return

  data_helper.proc_training_data()

  console.log jsondata
  d = new Date(Date.now())

  console.log "calling trend_chart.draw "+fmt(d)

  activity_chart = new ActivityChart(source+"-container", jsondata, data_helper)
  activity_chart.draw(d, "walking")
  activity_chart.update_daily(data_helper.fmt(d))
  activity_chart.set_callback(selection_callback)

  trend_chart = new TrendChart("moves-trend", jsondata, data_helper)
  trend_chart.draw(d, "walking")

  activity_chart.show_selection()
  trend_chart.show_curr_week(d)

selection_callback = (d) ->
  console.log "selection_callback called, "
  console.log d
  trend_chart.show_curr_week(new Date(Date.parse(d.date)))

is_weekly = () ->
  return ($("#moves-group input.is-weekly")[0].value == "yes")

get_curr_date = () ->
  return (new Date(Date.parse($("#moves-group input.curr-date")[0].value)))

get_current_meas = () ->
  return ($("#moves-group input.curr-meas")[0].value)

set_current_meas = (meas) ->
  $("#moves-group input.curr-meas")[0].value = meas

register_events = () ->
  $("#moves-left-arrow").click (evt) ->
    if is_weekly()
      curr = get_curr_date()
      date = curr.getDate()
      curr.setDate(date-7)
      activity_chart.update_weekly(fmt(curr))
      $("#moves-chart-svg").empty()
      activity_chart.draw(curr, get_current_meas())
    else
      curr = get_curr_date()
      curr.setDate(curr.getDate()-1)
      activity_chart.update_daily(fmt(curr))
      $("#moves-chart-svg").empty()
      activity_chart.draw(curr, get_current_meas())
    activity_chart.show_selection()
    trend_chart.show_curr_week(curr)
  $("#moves-right-arrow").click () ->
    if is_weekly()
      curr = get_curr_date()
      date = curr.getDate()
      curr.setDate(date+7)
      activity_chart.update_weekly(fmt(curr))
      $("#moves-chart-svg").empty()
      activity_chart.draw(curr, get_current_meas())
    else
      curr = get_curr_date()
      curr.setDate(curr.getDate()+1)
      activity_chart.update_daily(fmt(curr))
      $("#moves-chart-svg").empty()
      activity_chart.draw(curr, get_current_meas())
    activity_chart.show_selection()
    trend_chart.show_curr_week(curr)

  $("#moves-today-button").click () ->
    $("#moves-chart-svg").empty()
    today = new Date(Date.now())
    activity_chart.update_daily(fmt(today))
    activity_chart.draw(today, get_current_meas())
    activity_chart.show_selection()
    trend_chart.show_curr_week(curr)

  $("#moves-week-button").click () ->
    activity_chart.update_weekly($("#moves-group input.curr-date")[0].value)

  $("#moves-group div.steps").click (evt) ->
    set_selected(evt)
    set_current_meas("walking")
    curr = get_curr_date()
    $("#moves-chart-svg").empty()
    $("#moves-trend-svg").empty()
    activity_chart.draw(curr, get_current_meas())
    trend_chart.draw(curr, get_current_meas())

  $("#moves-group div.km-running").click (evt) ->
    set_selected(evt)
    set_current_meas("running")
    curr = get_curr_date()
    $("#moves-chart-svg").empty()
    $("#moves-trend-svg").empty()
    activity_chart.draw(curr, get_current_meas())
    trend_chart.draw(curr, get_current_meas())

  $("#moves-group div.km-cycling").click (evt) ->
    set_selected(evt)
    set_current_meas("cycling")
    curr = get_curr_date()
    $("#moves-chart-svg").empty()
    $("#moves-trend-svg").empty()
    activity_chart.draw(curr, get_current_meas())
    trend_chart.draw(curr, get_current_meas())

set_selected = (evt) ->
  clicked_block = evt.toElement.parentNode
  $("div.meas-block").removeClass("selected")
  clicked_block.classList.add("selected")

testchart = null
@test_trend_chart = () ->
  dat = {walking: [], running: [], cycling: []}
  steps = 1000
  currdate = Date.parse("2014-10-14 00:00:00")
  for i in [0..7]
    dat.walking.push({date: fmt(new Date(currdate)), steps: steps})
    steps = steps+500
    currdate = currdate+3*24*60*60*1000
  console.log dat.walking
  dh = new DataHelper(dat)
  testchart = new TrendChart("test-chart", dat, dh)
  testchart.draw(new Date(Date.parse("2014-11-03")), "walking")
  testchart.show_curr_week(new Date(Date.parse("2014-11-03")))

@debug = () ->
  console.log new Date(time_extent[0])+" - "+ new Date(time_extent[1])

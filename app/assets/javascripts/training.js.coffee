@training_loaded = () ->
  reset_ui()
  register_events()

  $("#training-button").addClass("selected")
  uid = $("#current_user_id")[0].value
  actions_url = "/users/"+uid+"/activities.json"
  d3.json(actions_url, data_received)

fmt = d3.time.format("%Y-%m-%d")
fmt_words = d3.time.format("%Y %b %e")
fmt_day = d3.time.format("%Y-%m-%d %a")
fmt_hms = d3.time.format("%Y-%m-%d %H:%M:%S")
data = []
#time_extent = []
time_scale = []
trend_time_scale = []
trend_time_extent = []
height = 0
trend_height = 0
trend_chart = null

data_received = (jsondata) ->
  datanum = get_data_size(jsondata)
  if datanum==0
    console.log "No data"
    return

  data = proc_training_data(jsondata)
  console.log data
  d = new Date(Date.now())
  update_daily(fmt(d))
  console.log "calling trend_chart.draw "+fmt(d)
  draw_activity_chart(fmt(d), "walking")
  trend_chart = new TrendChart("moves-trend", data)

  trend_chart.draw(fmt(d), "walking")
  show_selection()

get_monday = (date_ymd) ->
  d = new Date(Date.parse(date_ymd))
  dow = d.getDay()
  dow2 = if (dow==0) then 6 else (dow-1)
  d.setDate(d.getDate()-dow2)
  d.setHours(0)
  d.setMinutes(0)
  d.setSeconds(0)
  return new Date(d)

get_sunday = (date_ymd) ->
  d = new Date(Date.parse(date_ymd))
  dow = d.getDay()
  dow2 = if (dow==0) then 6 else (dow-1)

  d.setDate(d.getDate()+6-dow2)
  d.setHours(23)
  d.setMinutes(59)
  d.setSeconds(59)
  return new Date(d)

#
# Drawing the monthly chart
#
draw_activity_chart = (date_ymd, meas) ->
  console.log "draw_activity_chart "+date_ymd+" -> "+meas
  $("#moves-group input.curr-date")[0].value = date_ymd

  currdata = get_week_activities(date_ymd)
  console.log currdata
  margin = {top: 30, right: 10, bottom: 40, left: 50}
  aspect = 400/700
  width = $("#moves-chart").parent().width()-margin.left-margin.right
  height = aspect*width-margin.top-margin.bottom
  barwidth = width/14.0

  showdata = currdata.walking
  if meas=="running"
    showdata = currdata.running
  else if meas=="cycling"
    showdata = currdata.cycling

  if showdata.length==0
    console.log "no data"

  svg = d3.select($("#moves-chart-svg")[0])
  svg = svg
      .attr("width", width+margin.left+margin.right)
      .attr("height", height+margin.top+margin.bottom)
    .append("g")
      .attr("transform", "translate("+margin.left+","+margin.top+")")

  if showdata.length==0
    console.log "no data"
    svg.append("text")
      .text("No data!")
      .attr("class", "warn")
      .attr("x", width/2-margin.left)
      .attr("y", height/2)

  time_padding = 8*60*60*1000
  time_extent = [get_monday(date_ymd).getTime()-time_padding, get_sunday(date_ymd).getTime()-time_padding]
  console.log date_ymd
  console.log "draw_activity_chart time extent="+ new Date(time_extent[0])+" - "+ new Date(time_extent[1])
  console.log "monday="+fmt(new Date(get_monday(date_ymd).getTime()-time_padding))
  time_scale = d3.time.scale().domain(time_extent).range([0, width])

  if meas=='walking'
    x_getter = (d) -> d.steps
  else
    x_getter = (d) -> d.distance

  y_extent = d3.extent( showdata, x_getter )
  y_extent[0] = 0
  y_scale = d3.scale.linear().domain(y_extent).range([height, 0])

  svg
    .selectAll("rect."+meas)
    .data(showdata)
    .enter()
    .append("rect")
    .attr("class", meas)
    .attr("x", (d) -> time_scale(Date.parse(d.date))-barwidth/2)
    .attr("width", (d) -> barwidth)
    .attr("y", (d) -> y_scale(x_getter(d)))
    .attr("height", (d) -> height-y_scale(x_getter(d)))


  time_axis = d3.svg.axis()
    .scale(time_scale)
    .tickSize(8, 0)
    .ticks(d3.time.days)
  svg
    .append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0 ,"+height+")")
    .call(time_axis)
  svg.
    select(".x.axis")
    .append("text")
    .text("Date")
    .attr("x", (width / 2) - margin.right)
    .attr("y", margin.bottom / 1.2);


  if meas=='walking'
    y_axis_steps = d3.svg.axis()
      .scale(y_scale)
      .orient("left")
    svg
      .append("g")
      .attr("class", "y axis steps")
      .attr("transform", "translate(0, 0)")
      .call(y_axis_steps)
    svg.select(".y.axis.steps")
      .append("text")
      .text("Distance (steps)")
      .attr("x", -30)
      .attr("y", -10)
  else
    y_axis_km = d3.svg.axis()
      .scale(y_scale)
      .orient("left")
    svg
      .append("g")
      .attr("class", "y axis km")
      .attr("transform", "translate(0, 0)")
      .call(y_axis_km)
    svg.select(".y.axis.km")
      .append("text")
      .text("Distance (km)")
      .attr("x", -20)
      .attr("y", -10)


  d3.selectAll("rect")
    .on("mouseover", (d) ->
      d3.select(this)
        .classed("selected", true)

      act_date =  fmt_day(new Date(Date.parse(d.date)))
      act_type = d.group
      if act_type == "walking"
        act_value = d.steps.toString() + " steps"
      else
        act_value = (d.distance).toString()+" km"
      d3.select("#training-detail").html(act_date+" "+act_type+" "+act_value)

  ).on("mouseout", (d) ->
    d3.select(this)
      .classed("selected", false)
    d3.select("#training-detail").html("")
  ).on("click", (d) ->
    sel_date = fmt(new Date(Date.parse(d.date)))
    update_daily(sel_date)
    $("#moves-group input.curr-date")[0].value = sel_date
    show_selection()
  )

class TrendChart
  constructor: (@chart_element, @data) ->
    console.log "constructing trend chart..."

  draw: (date_ymd, meas) ->
    console.log "draw_trend_chart "+date_ymd+" -> "+meas

    margin = {top: 10, right: 30, bottom: 40, left: 30}
    aspect = 150/700
    trends_width = $("#"+@chart_element).parent().width()-margin.left-margin.right
    trend_height = aspect*trends_width-margin.top-margin.bottom

    showdata = @data.walking
    y_domain_getter = (d) -> d.steps
    if meas!="walking"
      console.log "meas = "+meas
      showdata = @data[meas]
      y_domain_getter = (d) -> d.distance

    if showdata.length==0
      console.log "trends no data"

    svg = d3.select($("#"+@chart_element+"-svg")[0])
    svg = svg
      .attr("width", trends_width+margin.left+margin.right)
      .attr("height", trend_height+margin.top+margin.bottom)
      .append("g")
        .attr("transform", "translate("+margin.left+","+margin.top+")")

    if showdata.length==0
      console.log "trends no data"
      svg.append("text")
        .text("No data!")
        .attr("class", "warn")
        .attr("x", trends_width/2-margin.left)
        .attr("y", trend_height/2)


    walking = @data.walking
    cycling = @data.cycling
    running = @data.running

    time_padding = 8*60*60*1000

    trend_time_extent = d3.extent(walking.concat(running.concat(cycling)), (d) -> Date.parse(d.date))
    time_to = get_sunday(fmt(new Date(trend_time_extent[1])))
    if time_to.getTime() > Date.now()
      time_to = new Date(Date.now())
      time_to.setHours(23)
      time_to.setMinutes(69)
      time_to.setSeconds(59)
    trend_time_extent = [get_monday(fmt(new Date(trend_time_extent[0]))).getTime()-time_padding, time_to.getTime()-time_padding]

    trend_time_scale = d3.time.scale().domain(trend_time_extent).range([0, trends_width])
    x_getter = (d) -> return(trend_time_scale(Date.parse(d.date)))

    y_extent = d3.extent( showdata,  y_domain_getter )
    y_extent[0] = 0
    y_extent[1] = y_extent[1]*1.1

    y_scale = d3.scale.linear().domain(y_extent).range([trend_height, 0])
    y_getter = (d) -> return(y_scale(y_domain_getter(d)))

    area = d3.svg.area()
      .interpolate("monotone")
      .x(x_getter)
      .y0(trend_height)
      .y1(y_getter)

    line = d3.svg.line()
      .interpolate("monotone")
      .x(x_getter)
      .y(y_getter)

  #  svg.append("clipPath")
  #    .attr("id", "clip")
  #    .append("rect")
  #    .attr("width", width)
  #    .attr("height", trend_height);

    svg.append("path")
      .attr("class", "area")
      .attr("clip-path", "url(#clip)")
      .attr("d", area(showdata));

    svg.append("path")
      .attr("class", "line")
      .attr("clip-path", "url(#clip)")
      .attr("d", line(showdata));


    time_axis = d3.svg.axis()
      .scale(trend_time_scale)
      .ticks(6)
      .tickSize(5, 0)
    svg
      .append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0 ,"+trend_height+")")
      .call(time_axis)
    svg.
      select(".x.axis")
      .append("text")
      .text("Date")
      .attr("x", (trends_width / 2) )
      .attr("y", margin.bottom*.8);

  show_curr_week: (currdate) ->
    monday = get_monday(fmt(new Date(parseInt(currdate))))
    monday.setHours(0)
    monday.setMinutes(0)
    monday.setSeconds(0)
    sunday = get_sunday(fmt(new Date(parseInt(currdate))))
    sunday.setHours(23)
    sunday.setMinutes(59)
    sunday.setSeconds(59)
    if sunday.getTime() > trend_time_extent[1]
      sunday = new Date(trend_time_extent[1])
    svg_trend = d3.select($("#moves-trend-svg g:first-child")[0])
    d3.selectAll($("#moves-trend-svg rect.sel")).remove()
    svg_trend.append("rect")
      .attr("class", "sel")
      .attr("x", (trend_time_scale(monday.getTime())+trend_time_scale(sunday.getTime()))/2)
      .attr("width", trend_time_scale(sunday.getTime())-trend_time_scale(monday.getTime()))
      .attr("y", 0)
      .attr("height", trend_height)

update_daily = (sel_date) ->
  $("#moves-group input.is-weekly")[0].value = ""
  today = fmt(new Date(Date.now()))
  if today==sel_date
    $("#moves-chart-date").html("Today")
  else
    $("#moves-chart-date").html(fmt_words(new Date(Date.parse(sel_date))))
  daily = get_daily_activities(sel_date)
  $("#moves-group div.steps").html(get_sum_measure(daily, 'steps', ['walking']))
  $("#moves-group div.km-running").html(get_sum_measure(daily, 'distance', ['running']).toFixed(2))
  $("#moves-group div.km-cycling").html(get_sum_measure(daily, 'distance', ['cycling']).toFixed(2))
  $("#moves-group div.calories").html(get_sum_measure(daily, 'calories', ['walking', 'running', 'cycling']))
  $("#moves-group div.distance").html(get_sum_measure(daily, 'distance', ['walking', 'running', 'cycling']).toFixed(2))
  duration_sec = get_sum_measure(daily, 'duration', ['walking', 'running', 'cycling'])
  timestr = get_hour(duration_sec)+"h "+get_min(duration_sec)+"min"
  $("#moves-group div.duration").html(timestr)

update_weekly = (sel_date) ->
  $("#moves-group input.is-weekly")[0].value = "yes"
  weekly = get_week_activities(sel_date)
  console.log sel_date
  monday =  get_monday(sel_date)
  sunday = get_sunday(sel_date)
  $("#moves-chart-date").html(fmt_words(monday)+" - "+fmt_words(sunday))
  $("#moves-group div.steps").html(get_sum_measure(weekly, 'steps', ['walking']))
  $("#moves-group div.km-running").html(get_sum_measure(weekly, 'distance', ['running']).toFixed(2))
  $("#moves-group div.km-cycling").html(get_sum_measure(weekly, 'distance', ['cycling']).toFixed(2))
  $("#moves-group div.calories").html(get_sum_measure(weekly, 'calories', ['walking', 'running', 'cycling']))
  $("#moves-group div.distance").html(get_sum_measure(weekly, 'distance', ['walking', 'running', 'cycling']).toFixed(2))
  duration_sec = get_sum_measure(weekly, 'duration', ['walking', 'running', 'cycling'])
  timestr = get_hour(duration_sec)+"h "+get_min(duration_sec)+"min"
  $("#moves-group div.duration").html(timestr)

is_weekly = () ->
  return ($("#moves-group input.is-weekly")[0].value == "yes")

get_curr_date = () ->
  return (new Date(Date.parse($("#moves-group input.curr-date")[0].value)))

get_current_meas = () ->
  return ($("#moves-group input.curr-meas")[0].value)
set_current_meas = (meas) ->
  $("#moves-group input.curr-meas")[0].value = meas

show_selection = () ->
  currdate = Date.parse($("#moves-group input.curr-date")[0].value)
  console.log "show selection " + currdate

  svg = d3.select($("#moves-chart-svg g:first-child")[0])
  d3.selectAll($("#moves-chart-svg line.sel")).remove()
  svg.insert("line", ":first-child")
    .attr("class", "sel")
    .attr("x1", time_scale(currdate))
    .attr("y1", -10)
    .attr("x2", time_scale(currdate))
    .attr("y2", height)

  trend_chart.show_curr_week(currdate)


#  [1412726400000, 1414972800000]
#  [1414335600000, 1414940399000]
register_events = () ->
  $("#moves-left-arrow").click (evt) ->
    if is_weekly()
      curr = get_curr_date()
      date = curr.getDate()
      curr.setDate(date-7)
      update_weekly(fmt(curr))
      $("#moves-chart-svg").empty()
      draw_activity_chart(fmt(curr), get_current_meas())
    else
      curr = get_curr_date()
      curr.setDate(curr.getDate()-1)
      update_daily(fmt(curr))
      $("#moves-chart-svg").empty()
      draw_activity_chart(fmt(curr), get_current_meas())
    show_selection()
  $("#moves-right-arrow").click () ->
    if is_weekly()
      curr = get_curr_date()
      date = curr.getDate()
      curr.setDate(date+7)
      update_weekly(fmt(curr))
      $("#moves-chart-svg").empty()
      draw_activity_chart(fmt(curr), get_current_meas())
    else
      curr = get_curr_date()
      curr.setDate(curr.getDate()+1)
      update_daily(fmt(curr))
      $("#moves-chart-svg").empty()
      draw_activity_chart(fmt(curr), get_current_meas())
    show_selection()

  $("#moves-today-button").click () ->
    $("#moves-chart-svg").empty()
    today = new Date(Date.now())
    update_daily(fmt(today))
    draw_activity_chart(fmt(today), get_current_meas())
    show_selection()

  $("#moves-week-button").click () ->
    update_weekly($("#moves-group input.curr-date")[0].value)

  $("#moves-group div.steps").click (evt) ->
    set_selected(evt)
    set_current_meas("walking")
    curr = get_curr_date()
    $("#moves-chart-svg").empty()
    $("#moves-trend-svg").empty()
    draw_activity_chart(fmt(curr), get_current_meas())
    trend_chart.draw(fmt(curr), get_current_meas())

  $("#moves-group div.km-running").click (evt) ->
    set_selected(evt)
    set_current_meas("running")
    curr = get_curr_date()
    $("#moves-chart-svg").empty()
    $("#moves-trend-svg").empty()
    draw_activity_chart(fmt(curr), get_current_meas())
    trend_chart.draw(fmt(curr), get_current_meas())

  $("#moves-group div.km-cycling").click (evt) ->
    set_selected(evt)
    set_current_meas("cycling")
    curr = get_curr_date()
    $("#moves-chart-svg").empty()
    $("#moves-trend-svg").empty()
    draw_activity_chart(fmt(curr), get_current_meas())
    trend_chart.draw(fmt(curr), get_current_meas())




set_selected = (evt) ->
  clicked_block = evt.toElement.parentNode
  $("div.meas-block").removeClass("selected")
  clicked_block.classList.add("selected")

get_hour = (sec) ->
  Math.floor(sec/60.0/60.0).toString()

get_min = (sec) ->
  Math.floor((sec%(60*60))/60).toString()

get_data_size = (data) ->
  h = {}
  walking = if data.walking then data.walking else []
  running = if data.running then data.running else []
  cycling = if data.cycling then data.cycling else []
  for d in walking.concat(running.concat(cycling))
    curr = fmt(new Date(Date.parse(d.date)))
    h[curr] = true
  datanum = Object.keys(h).length
  return datanum

days_in_month = (year, month) ->
  d = new Date(Date.parse(year+"-"+month))
  return new Date(d.getYear(), d.getMonth()+1, 0).getDate()

conv_to_km = (data) ->
  for d in data
    d.distance = d.distance/1000

add_missing_days = (year, month, activity_group, training_arr) ->
  console.log activity_group
  result = []
  rec = training_arr.shift()
  console.log rec
  rec_date = fmt(new Date(Date.parse(rec.date)))
  console.log rec_date
  for i in [1...days_in_month(year, month)]
    loop_date = fmt(new Date(year, month-1, i))
    found = false
    while rec_date == loop_date
      result.push(rec)
      found = true
      rec = training_arr.shift()
      rec_date = if rec then fmt(new Date(Date.parse(rec.date))) else undefined
    if not found
      result.push({activity: activity_group, group: activity_group, calories: 0, date: loop_date, distance: 0, duration: 0, steps:0})
  return result

proc_training_data = (data) ->
  conv_to_km(data.walking)
  conv_to_km(data.running)
  conv_to_km(data.cycling)
  return data

get_daily_activities = (date) ->
  result = {'walking': [], 'running':[], 'cycling': [], 'transport': []}
  walking = if data.walking then data.walking else []
  running = if data.running then data.running else []
  cycling = if data.cycling then data.cycling else []
  transport = if data.transport then data.transport else []

  for d in walking.concat(running.concat(cycling.concat(transport)))
    if fmt(new Date(Date.parse(d.date))) == date
      result[d.group].push(d)
  return result

get_sum_measure = (dat, measure, activity_types) ->
  result = 0.0
  for k in activity_types
    if dat[k]
      for item in dat[k]
        result = result + item[measure]
  return result

get_week_activities = (date_ymd) ->
  console.log "get_week_act"
  result = {'walking': [], 'running':[], 'cycling': [], 'transport': []}
  walking = if data.walking then data.walking else []
  running = if data.running then data.running else []
  cycling = if data.cycling then data.cycling else []
  transport = if data.transport then data.transport else []
  monday = get_monday(date_ymd)
  sunday = get_sunday(date_ymd)
  console.log "from="+fmt_hms(monday)+" to="+fmt_hms(sunday)
  for d in walking.concat(running.concat(cycling.concat(transport)))
    curr = new Date(Date.parse(d.date))
    if curr > monday and curr<=sunday
      result[d.group].push(d)
  return result

testchart = null
@test_trend_chart = () ->
  dat = {walking: []}
  steps = 1000
  currdate = Date.parse("2014-11-03 00:00:00")
  for i in [0..7]
    dat.walking.push({date: fmt(new Date(currdate)), steps: steps})
    steps = steps+100
    currdate = new Date(currdate+24*60*60)
  testchart = new TrendChart("test-chart", dat)
  testchart.draw("2014-11-03", "walking")

@debug = () ->
  console.log new Date(time_extent[0])+" - "+ new Date(time_extent[1])
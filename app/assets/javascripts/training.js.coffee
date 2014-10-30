@training_loaded = () ->
  reset_ui()

  $("#training-button").addClass("selected")
  uid = $("#current_user_id")[0].value
  actions_url = "/users/"+uid+"/activities.json"
  d3.json(actions_url, data_received)

fmt = d3.time.format("%Y-%m-%d")
fmt_day = d3.time.format("%Y-%m-%d %a")
fmt_hms = d3.time.format("%Y-%m-%d %H:%M:%S")
data = []

data_received = (jsondata) ->
  datanum = get_data_size(jsondata)
  if datanum==0
    console.log "No data"
    return

  data = proc_training_data("2014", "10", jsondata)
  console.log data
  d = new Date(Date.now())
  draw_moves_chart(fmt(d))


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
draw_moves_chart = (date_ymd) ->
  console.log "draw_moves_chart "+date_ymd
  $("#moves-curr-date")[0].value = date_ymd

  currdata = get_week_activities(date_ymd)
  console.log currdata
  margin = {top: 30, right: 10, bottom: 40, left: 50}
  aspect = 400/700
  width = $("#moves-chart").parent().width()-margin.left-margin.right
  height = aspect*width-margin.top-margin.bottom

  barwidth = width/14.0

  moves_chart = $("#moves-chart")[0]
  svg = d3.select(moves_chart)
    .append("svg")
      .attr("width", width+margin.left+margin.right)
      .attr("height", height+margin.top+margin.bottom)
      .attr("id", "moves-chart-svg")
    .append("g")
      .attr("transform", "translate("+margin.left+","+margin.top+")")

#  time_extent = d3.extent( currdata.walking.concat(currdata.running).concat(currdata.cycling), (d) ->
#    Date.parse(d.date) )
#  time_extent[0] = time_extent[0]-(2*60*60*1000)
#  time_extent[1] = time_extent[1]+(2*60*60*1000)
  time_padding = 8*60*60*1000
  time_extent = [get_monday(date_ymd).getTime()-time_padding, get_sunday(date_ymd).getTime()-time_padding]
  time_scale = d3.time.scale().domain(time_extent).range([0, width])

  y_extent_km = d3.extent( currdata.running.concat(currdata.cycling), (d) ->
    d.distance
  )
  y_scale_km = d3.scale.linear().domain(y_extent_km).range([height, 0])
  console.log y_extent_km

  y_extent_steps = d3.extent( currdata.walking, (d) ->
    d.steps
  )
  y_extent_steps[0] = 0
  y_scale_steps = d3.scale.linear().domain(y_extent_steps).range([height, 0])
  console.log "y scale steps"
  console.log y_scale_steps
  console.log y_extent_steps

#  offset = 24*1000*60*60
#  svg
#    .selectAll("rect.cycling")
#    .data(currdata.cycling)
#    .enter()
#    .append("rect")
#    .attr("class", "cycling")
#    .attr("x", (d) -> time_scale(Date.parse(d.date)+offset))
#    .attr("width", (d) -> barwidth)
#    .attr("y", (d) -> y_scale_km(d.distance))
#    .attr("height", (d) -> height-y_scale_km(d.distance))

  svg
    .selectAll("rect.walking")
    .data(currdata.walking)
    .enter()
    .append("rect")
    .attr("class", "walking")
    .attr("x", (d) -> time_scale(Date.parse(d.date))-barwidth/2)
    .attr("width", (d) -> barwidth)
    .attr("y", (d) -> y_scale_steps(d.steps))
    .attr("height", (d) -> height-y_scale_steps(d.steps))

#  svg
#    .selectAll("rect.running")
#    .data(currdata.running)
#    .enter()
#    .append("rect")
#    .attr("class", "running")
#    .attr("x", (d) -> time_scale(Date.parse(d.date)+offset)+2*barwidth)
#    .attr("width", (d) -> barwidth)
#    .attr("y", (d) -> y_scale_km(d.distance))
#    .attr("height", (d) -> height-y_scale_km(d.distance))

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
    .attr("y", margin.bottom / 1.5);


  y_axis_steps = d3.svg.axis()
    .scale(y_scale_steps)
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

#  y_axis_km = d3.svg.axis()
#    .scale(y_scale_km)
#    .orient("left")
#  svg
#    .append("g")
#    .attr("class", "y axis km")
#    .attr("transform", "translate(0, 0)")
#    .call(y_axis_km)
#  svg.select(".y.axis.km")
#    .append("text")
#    .text("Distance (km)")
#    .attr("x", -20)
#    .attr("y", -10)


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
    $("#moves-chart-date").html(sel_date)
    daily = get_daily_activities(sel_date)
    $("#steps-walked-daily").html(get_sum_measure(daily, 'steps', ['walking']))
    $("#km-running-daily").html(get_sum_measure(daily, 'distance', ['running']).toFixed(2))
    $("#km-cycling-daily").html(get_sum_measure(daily, 'distance', ['cycling']).toFixed(2))
    $("#calories-daily").html(get_sum_measure(daily, 'calories', ['walking', 'running', 'cycling']))
    $("#distance-daily").html(get_sum_measure(daily, 'distance', ['walking', 'running', 'cycling']).toFixed(2))
    duration_sec = get_sum_measure(daily, 'duration', ['walking', 'running', 'cycling'])
    timestr = get_hour(duration_sec)+"h "+get_min(duration_sec)+"min"
    $("#duration-daily").html(timestr)

    weekly = get_week_activities(sel_date)
    console.log sel_date
    monday =  get_monday(sel_date)
    sunday = get_sunday(sel_date)
    $("#moves-weekly-date").html(fmt(monday)+" - "+fmt(sunday))
    $("#steps-walked-weekly").html(get_sum_measure(weekly, 'steps', ['walking']))
    $("#km-cycling-weekly").html(get_sum_measure(weekly, 'distance', ['cycling']).toFixed(2))
    $("#km-running-weekly").html(get_sum_measure(weekly, 'distance', ['running']).toFixed(2))
    $("#calories-weekly").html(get_sum_measure(weekly, 'calories', ['walking', 'running', 'cycling']))
    $("#distance-weekly").html(get_sum_measure(weekly, 'distance', ['walking', 'running', 'cycling']).toFixed(2))
    duration_sec = get_sum_measure(weekly, 'duration', ['walking', 'running', 'cycling'])
    timestr = get_hour(duration_sec)+"h "+get_min(duration_sec)+"min"
    $("#duration-weekly").html(timestr)
  )
  $("#moves-left-arrow").click () ->
    curr = new Date(Date.parse($("#moves-curr-date")[0].value))
    curr.setDate(curr.getDate()-1)
    $("#moves-chart-svg").remove()
    draw_moves_chart(fmt(curr))

  $("#moves-right-arrow").click () ->
    curr = new Date(Date.parse($("#moves-curr-date")[0].value))
    curr.setDate(curr.getDate()+1)
    $("#moves-chart-svg").remove()
    draw_moves_chart(fmt(curr))


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

proc_training_data = (year, month, data) ->
  conv_to_km(data.walking)
  conv_to_km(data.running)
  conv_to_km(data.cycling)
#  result = {}
#  result['walking'] = add_missing_days(year, month, "walking", data.walking)
#  result['running'] = add_missing_days(year, month, "running", data.running)
#  result['cycling'] = add_missing_days(year, month, "cycling", data.cycling)
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

@training_loaded = () ->
  reset_ui()

  $("#training-button").addClass("selected")
  uid = $("#current_user_id")[0].value
  actions_url = "/users/"+uid+"/activities.json?year=2014&month=10"
  d3.json(actions_url, draw_moves_chart)

fmt = d3.time.format("%Y-%m-%d")
data = []

#
# Drawing the monthly chart
#
draw_moves_chart = (jsondata) ->
  console.log "draw_moves_chart"

  data = proc_training_data("2014", "10", jsondata)
  console.log data

  margin = {top: 30, right: 50, bottom: 50, left: 30}
  aspect = 300/700
  width = $("#moves-chart").parent().width()-margin.left-margin.right
  height = aspect*width-margin.top-margin.bottom

  datanum = get_data_size(data)
  barwidth = width/(datanum)/3-2

  moves_chart = $("#moves-chart")[0]
  svg = d3.select(moves_chart)
    .append("svg")
      .attr("width", width+margin.left+margin.right)
      .attr("height", height+margin.top+margin.bottom)
    .append("g")
      .attr("transform", "translate("+margin.left+","+margin.top+")")

  time_extent = d3.extent( data.walking.concat(data.running).concat(data.cycling), (d) ->
    Date.parse(d.date) )

  time_extent[0] = time_extent[0]-(2*60*60*1000)
  time_extent[1] = time_extent[1]+(2*60*60*1000)

  time_scale = d3.time.scale().domain(time_extent).range([0, width-40])

  y_extent_km = d3.extent( data.running.concat(data.cycling), (d) ->
    d.distance
  )
  y_scale_km = d3.scale.linear().domain(y_extent_km).range([height, 0])
  console.log y_extent_km

  y_extent_steps = d3.extent( data.walking, (d) ->
    d.steps
  )
  y_scale_steps = d3.scale.linear().domain(y_extent_steps).range([height, 0])
  console.log y_extent_steps

  offset = 2.5*1000*60*60
  svg
    .selectAll("rect.cycling")
    .data(data.cycling)
    .enter()
    .append("rect")
    .attr("class", "cycling")
    .attr("x", (d) -> time_scale(Date.parse(d.date)+offset))
    .attr("width", (d) -> barwidth)
    .attr("y", (d) -> y_scale_km(d.distance))
    .attr("height", (d) -> height-y_scale_km(d.distance))

  svg
    .selectAll("rect.walking")
    .data(data.walking)
    .enter()
    .append("rect")
    .attr("class", "walking")
    .attr("x", (d) -> time_scale(Date.parse(d.date)+offset)+barwidth)
    .attr("width", (d) -> barwidth)
    .attr("y", (d) -> y_scale_steps(d.steps))
    .attr("height", (d) -> height-y_scale_steps(d.steps))

  svg
    .selectAll("rect.running")
    .data(data.running)
    .enter()
    .append("rect")
    .attr("class", "running")
    .attr("x", (d) -> time_scale(Date.parse(d.date)+offset)+2*barwidth)
    .attr("width", (d) -> barwidth)
    .attr("y", (d) -> y_scale_km(d.distance))
    .attr("height", (d) -> height-y_scale_km(d.distance))



  time_axis = d3.svg.axis()
    .scale(time_scale)
    .tickSize(8, 0)
  svg
    .append("g")
    .attr("class", "x axis")
    .attr("transform", "translate("+17+" ,"+height+")")
    .call(time_axis)
  svg.
    select(".x.axis")
    .append("text")
    .text("Date")
    .attr("x", (width / 2) - margin.right)
    .attr("y", margin.bottom / 1.5);


  y_axis_steps = d3.svg.axis()
    .scale(y_scale_steps)
    .orient("right")
  svg
    .append("g")
    .attr("class", "y axis steps")
    .attr("transform", "translate("+(width-8)+", 0)")
    .call(y_axis_steps)
  svg.select(".y.axis.steps")
    .append("text")
    .text("Distance (steps)")
    .attr("x", -40)
    .attr("y", -10)

  y_axis_km = d3.svg.axis()
    .scale(y_scale_km)
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

      act_date =  fmt(new Date(Date.parse(d.date)))
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
    $("#moves-daily-date").html(sel_date)
    daily = get_daily_activities(sel_date)
    console.log("DAILY "+sel_date)
    console.log(daily)
    $("#steps-walked-daily").html(daily['walking'].steps)
    $("#km-running-daily").html(daily['running'].distance)
    $("#km-cycling-daily").html(daily['cycling'].distance)
  )

get_data_size = (data) ->
  h = {}
  for d in data.walking.concat(data.running.concat(data.cycling))
    curr = fmt(new Date(Date.parse(d.date)))
    h[curr] = true
  datanum = Object.keys(h).length
  console.log datanum
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
    console.log "doing: "+loop_date
    console.log "\trec_date: "+rec_date
    while rec_date == loop_date
      console.log "\tmatch"
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
  result = {}
  result['walking'] = add_missing_days(year, month, "walking", data.walking)
  result['running'] = add_missing_days(year, month, "running", data.running)
  result['cycling'] = add_missing_days(year, month, "cycling", data.cycling)
  return result

get_daily_activities = (date) ->
  result = {}
  for d in data.walking.concat(data.running.concat(data.cycling))
    if fmt(new Date(Date.parse(d.date))) == date
      result[d.group] = d
  if not result['walking']
    result['walking'] = 0
  if not result['running']
    result['running'] = 0
  if not result['cycling']
    result['cycling'] = 0
  return result
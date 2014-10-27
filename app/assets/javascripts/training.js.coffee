@training_loaded = () ->
  reset_ui()
  $("#training-button").addClass("selected")
  uid = $("#current_user_id")[0].value
  actions_url = "/users/"+uid+"/activities.json"
  d3.json(actions_url, draw_moves_chart)

draw_moves_chart = (data) ->
  console.log "draw_moves_chart"
  console.log data

  margin = 50
  aspect = 300/700
  width = $("#moves-chart").parent().width()-2*margin
  height = aspect*width-2*margin

  datanum = get_data_size(data)

  barwidth = width/datanum/3-2

  console.log "bw = "+barwidth
  moves_chart = $("#moves-chart")[0]
  svg = d3.select(moves_chart)
    .append("svg")
      .attr("width", width+2*margin)
      .attr("height", height+2*margin)
    .append("g")
      .attr("transform", "translate("+margin+","+margin+")")

  time_extent = d3.extent( data.walking.concat(data.running).concat(data.cycling), (d) ->
    Date.parse(d.date) )
  console.log time_extent
  time_extent[0] = time_extent[0]-(2*60*60*1000)
  time_extent[1] = time_extent[1]+(2*60*60*1000)

  time_scale = d3.time.scale().domain(time_extent).range([0, width])

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

  svg
    .selectAll("rect.walking")
    .data(data.walking)
    .enter()
    .append("rect")
    .attr("class", "walking")

  svg
    .selectAll("rect.running")
    .data(data.running)
    .enter()
    .append("rect")
    .attr("class", "running")

  svg
    .selectAll("rect.cycling")
    .data(data.cycling)
    .enter()
    .append("rect")
    .attr("class", "cycling")

  svg.selectAll("rect.walking")
    .attr("x", (d) -> time_scale(Date.parse(d.date))-barwidth)
    .attr("width", (d) -> barwidth)
    .attr("y", (d) -> y_scale_steps(d.steps))
    .attr("height", (d) -> height-y_scale_steps(d.steps))

  svg.selectAll("rect.running")
  .attr("x", (d) -> time_scale(Date.parse(d.date))+barwidth)
  .attr("width", (d) -> barwidth)
  .attr("y", (d) -> y_scale_km(d.distance))
  .attr("height", (d) -> height-y_scale_km(d.distance))


  svg.selectAll("rect.cycling")
  .attr("x", (d) -> time_scale(Date.parse(d.date)))
  .attr("width", (d) -> barwidth)
  .attr("y", (d) -> y_scale_km(d.distance))
  .attr("height", (d) -> height-y_scale_km(d.distance))

  time_axis = d3.svg.axis()
    .scale(time_scale)
  svg
    .append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0 ,"+height+")")
    .call(time_axis)
  svg.
    select(".x.axis")
    .append("text")
    .text("Date")
    .attr("x", (width / 2) - margin)
    .attr("y", margin / 1.5);


  y_axis_steps = d3.svg.axis()
    .scale(y_scale_steps)
    .orient("right")
  svg
    .append("g")
    .attr("class", "y axis steps")
    .attr("transform", "translate("+width+", 0)")
    .call(y_axis_steps)
  svg.select(".y.axis.steps")
    .append("text")
    .text("Distance (steps)")
    .attr("x", 100)
    .attr("y", 100)

  y_axis_km = d3.svg.axis()
    .scale(y_scale_km)
    .orient("left")
  svg
    .append("g")
    .attr("class", "y axis")
    .attr("transform", "translate(0, 0)")
    .call(y_axis_km)


  d3.selectAll("rect")
    .on("mouseover", (d) ->
      d3.select(this)
        .classed("selected", true)
      fmt = d3.time.format("%Y-%m-%d")
      act_date =  fmt(new Date(Date.parse(d.date)))
      act_type = d.group
      if act_type == "walking"
        act_value = d.steps.toString() + " steps"
      else
        act_value = (d.distance/1000).toString()+" km"
      d3.select("#training-detail").html(act_date+" "+act_type+" "+act_value)

  ).on("mouseout", (d) ->
    d3.select(this)
      .classed("selected", false)
    d3.select("#training-detail").html("")
  )

get_data_size = (data) ->
  h = {}
  fmt = d3.time.format("%Y-%m-%d")
  for d in data.walking.concat(data.running).concat(data.cycling)
    curr = fmt(new Date(Date.parse(d.date)))
    h[curr] = true
  datanum = Object.keys(h).length
  console.log datanum
  return datanum

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
  width = $("#moves-chart").parent().width()
  height = aspect*width

  moves_chart = $("#moves-chart")[0]
  d3.select(moves_chart) .append("svg")
    .attr("width", width)
    .attr("height", height)

  time_extent = d3.extent( data.walking.concat(data.running), (d) ->
    Date.parse(d.date) )

  time_scale = d3.time.scale().domain(time_extent).range([margin, width])

  y_extent = d3.extent( data.walking.concat(data.running), (d) ->
    d.distance
  )
  y_scale = d3.scale.linear().domain(y_extent).range([height, margin])
  console.log y_extent

  d3.select("svg") .selectAll("circle.walking")
    .data(data.walking).enter() .append("circle")
    .attr("class", "walking");

  d3.select("svg") .selectAll("circle.running")
  .data(data.running).enter() .append("circle")
  .attr("class", "running");

  d3.selectAll("circle")
    .attr("cy", (d) -> y_scale(d.distance))
    .attr("cx", (d) -> time_scale(Date.parse(d.date)))
    .attr("r", 3)

  time_axis = d3.svg.axis().scale(time_scale)
  d3.select("svg").append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0,"+height+")")
    .call(time_axis)


  y_axis = d3.svg.axis()
    .scale(y_scale)
    .orient("left")
  d3.select("svg")
    .append("g")
    .attr("class", "y axis")
    .attr("transform", "translate("+margin+", 0)")
    .call(y_axis)
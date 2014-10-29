@health_loaded = () ->
  reset_ui()
  $("#health-button").addClass("selected")
  uid = $("#current_user_id")[0].value
  console.log uid
  actions_url = "/users/" + uid + "/measurements.json"
  d3.json(actions_url, draw_withings_chart)

draw_withings_chart = (data) ->
  console.log "draw_withings_chart"
  console.log data

  margin = 50
  width = 700
  height = 300
  console.log("megjo")
  d3div = $("#chart-div")[0]
  console.log(d3div)

  d3.select(d3div).append("svg")
  .attr("width", width)
  .attr("height", height)

  time_extent = d3.extent(data, (d) ->  new Date(d.date))

  console.log time_extent
  time_scale = d3.time.scale().domain(time_extent).range([margin, width])

  y_extent = d3.extent(data, (d) ->
    d.pulse)
  y_extent[0] = Math.min(y_extent[0], 50)
  y_extent[1] = Math.max(y_extent[1], 150)
  y_scale = d3.scale.linear().range([height - margin, margin]).domain(y_extent)

  console.log 'y_extent: ' + y_extent

  ldata = create_lines(y_extent)

  d3.select("svg").selectAll("line").data(ldata).enter().append("svg:line").
  attr("x1", time_scale(time_extent[0])).
  attr("y1", (d) -> y_scale(d.x)).
  attr("x2", time_scale(time_extent[1])).
  attr("y2", (d) -> y_scale(d.x)).
  attr("stroke", (d) -> d.color).
  attr("stroke-width", 1).
  attr("opacity", 1)

  time_axis = d3.svg.axis().scale(time_scale)
  d3.select("svg").append("g")
  .attr("class", "x axis")
  .attr("transform", "translate(0," + (height - margin) + ")")
  .attr("stroke-width", "0")
  .call(time_axis)

  y_axis = d3.svg.axis().scale(y_scale).orient("left")
  d3.select("svg").append("g")
  .attr("class", "y axis")
  .attr("transform", "translate(" + margin + ", 0 )")
  .attr("stroke-width", "0")
  .call(y_axis)

  d3.select(".x.axis").append("text")
  .text("Date of measurement").attr("x", (width / 2) - margin)
  .attr("y", margin / 1.5)
  d3.select(".y.axis")
  .append("text").text("Heart rate")
  .attr("transform", "rotate (-90, -43, 0) translate(-280)")

  d3.select("svg").selectAll("circle").data(data)
  .enter().append("circle")

  d3.selectAll("circle")
  .attr("cx", (d) -> time_scale(new Date(d.date)))
  .attr("cy", (d) -> y_scale(d.pulse))
  d3.selectAll("circle").attr("r", 5)

create_lines = (r) ->
  start = r[0] - r[0] % 5
  end = r[1] - r[1] % 5
  i = start
  ret = []
  console.log(start)
  while i <= end
    col = '#e0e0e0'
    if i % 25 == 0
      col = '#c0c0c0'
    ret.push({x: i, color: col})
    i += 5
  console.log("end jo")
  return ret

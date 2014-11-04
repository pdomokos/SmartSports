@health_loaded = () ->
  reset_ui()
  $("#new-activity-form-button").click (event) ->
    console.log 'started show activity'
    $("#measurement-form").addClass("hidden")
    $("#activity-form").removeClass("hidden")

  $("#new-measurement-form-button").click (event) ->
    console.log 'started show meas'
    $("#activity-form").addClass("hidden")
    $("#measurement-form").removeClass("hidden")

  $("#new-activity-button").click (event) ->
    new_activity_submit_handler(event)

  $("#new-measurement-button").click (event) ->
    new_measurement_submit_handler(event)

  $("#health-button").addClass("selected")
  uid = $("#current_user_id")[0].value
  console.log uid
  actions_url = "/users/" + uid + "/measurements.json"
  d3.json(actions_url, draw_charts)

draw_charts = (data) ->
  draw_withings_chart(data)
  draw_withings_chart2(data)


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

  time_extent = d3.extent(data, (d) ->
    new Date(d.date))

  console.log time_extent
  time_scale = d3.time.scale().domain(time_extent).range([margin, width])

  y_extent = d3.extent(data, (d) ->
    d.pulse)
  y_extent[0] = Math.min(y_extent[0], 50)
  y_extent[1] = Math.max(y_extent[1], 150)
  y_scale = d3.scale.linear().range([height - margin, margin]).domain(y_extent)

  console.log 'y_extent: ' + y_extent

  ldata = create_lines(y_extent)

  d3.select(d3div).select("svg").selectAll("line").data(ldata).enter().append("svg:line").
  attr("x1", time_scale(time_extent[0])).
  attr("y1", (d) ->
    y_scale(d.x)).
  attr("x2", time_scale(time_extent[1])).
  attr("y2", (d) ->
    y_scale(d.x)).
  attr("stroke", (d) ->
    d.color).
  attr("stroke-width", 1).
  attr("opacity", 1)

  time_axis = d3.svg.axis().scale(time_scale)
  d3.select(d3div).select("svg").append("g")
  .attr("class", "x axis")
  .attr("transform", "translate(0," + (height - margin) + ")")
  .attr("stroke-width", "0")
  .call(time_axis)

  y_axis = d3.svg.axis().scale(y_scale).orient("left")
  d3.select(d3div).select("svg").append("g")
  .attr("class", "y axis")
  .attr("transform", "translate(" + margin + ", 0 )")
  .attr("stroke-width", "0")
  .call(y_axis)

  d3.select(d3div).select(".x.axis").append("text")
  .text("Date of measurements").attr("x", (width / 2) - margin)
  .attr("y", margin / 1.5)
  d3.select(d3div).select(".y.axis")
  .append("text").text("Heart rate")
  .attr("transform", "rotate (-90, -43, 0) translate(-280)")

  d3.select(d3div).select("svg").selectAll("circle").data(data)
  .enter().append("circle")

  d3.select(d3div).selectAll("circle")
  .attr("cx", (d) ->
    time_scale(new Date(d.date)))
  .attr("cy", (d) ->
    y_scale(d.pulse))
  d3.select(d3div).selectAll("circle").attr("r", 5)

draw_withings_chart2 = (data) ->
  console.log "draw_withings_chart"
  console.log data

  margin = 50
  width = 700
  height = 300
  console.log("megjo")
  d3div = $("#blood-pressure-chart-div")[0]
  console.log(d3div)

  container = d3.select(d3div).append("svg")
  .attr("width", width)
  .attr("height", height)

  time_extent = d3.extent(data, (d) ->
    new Date(d.date))

  console.log time_extent
  time_scale = d3.time.scale().domain(time_extent).range([margin, width])

  y_extent1 = d3.extent(data, (d) ->
    d.systolicbp)
  y_extent2 = d3.extent(data, (d) ->
    d.diastolicbp)
  y_extent = []
  y_extent[0] = Math.min(y_extent2[0], 50)
  y_extent[1] = Math.max(y_extent1[1], 150)
  y_scale = d3.scale.linear().range([height - margin, margin]).domain(y_extent)

  console.log 'y_extent: ' + y_extent

  ldata = create_lines(y_extent)
  console.log ldata

  d3.select(d3div).select("svg").selectAll("line").data(ldata).enter().append("svg:line").
  attr("x1", time_scale(time_extent[0])).
  attr("y1", (d) ->
    y_scale(d.x)).
  attr("x2", time_scale(time_extent[1])).
  attr("y2", (d) ->
    y_scale(d.x)).
  attr("stroke", (d) ->
    d.color).
  attr("stroke-width", 1).
  attr("opacity", 1)

  time_axis = d3.svg.axis().scale(time_scale)
  d3.select(d3div).select("svg").append("g")
  .attr("class", "x axis")
  .attr("transform", "translate(0," + (height - margin) + ")")
  .attr("stroke-width", "0")
  .call(time_axis)

  y_axis = d3.svg.axis().scale(y_scale).orient("left")
  d3.select(d3div).select("svg").append("g")
  .attr("class", "y axis")
  .attr("transform", "translate(" + margin + ", 0 )")
  .attr("stroke-width", "0")
  .call(y_axis)

  d3.select(d3div).select(".x.axis").append("text")
  .text("Date of measurements").attr("x", (width / 2) - margin)
  .attr("y", margin / 1.5)
  d3.select(d3div).select(".y.axis")
  .append("text").text("Blood pressure")
  .attr("transform", "rotate (-90, -43, 0) translate(-280)")

  cdata = create_circles(data)

  d3.select(d3div).select("svg").selectAll("circle").data(cdata)
  .enter().append("circle")

  d3.select(d3div).selectAll("circle")
  .attr("cx", (d) ->
    time_scale(new Date(d.date)))
  .attr("cy", (d) ->
    y_scale(d.y))

  d3.select(d3div).selectAll("circle").attr("r", 5)

  cldata = create_circle_lines(data)
  console.log cldata


  d3.select(d3div).select("svg").selectAll("line").data(cldata).enter().append("svg:line")
  .attr("x1", (d) -> time_scale( Date.parse(d.date)))
  .attr("y1", (d) -> y_scale(d.yg))
  .attr("x2", (d) -> time_scale(Date.parse(d.date)))
  .attr("y2", (d) -> y_scale(d.yy))
  .attr("stroke", (d) -> d.color)
  .attr("stroke-width", 3)



  container.append("svg:line")
    .attr("x1", time_scale(new Date(cldata[3].date)))
    .attr("y1", y_scale(cldata[0].yg))
    .attr("x2", time_scale(new Date(cldata[3].date)))
    .attr("y2", y_scale(cldata[0].yy))
    .attr("stroke", cldata[0].color)
    .attr("stroke-width", 3)

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

create_circles = (data) ->
  ret = []
  col = '#e0e0e0'
  for i in [0...data.length]
    ret.push({y: data[i].systolicbp, date: data[i].date, color: col})
    ret.push({y: data[i].diastolicbp, date: data[i].date, color: col})
  return ret

create_circle_lines = (data) ->
  ret = []
  col = 'black'
  for i in [0...data.length]
    ret.push({yg: data[i].systolicbp, yy: data[i].diastolicbp, date: data[i].date, color: col})
  return ret

@new_activity_submit_handler = (event) ->
  event.preventDefault()
  values = $("#new-activity-form").serialize()
  $.ajax '/activities',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE activity AJAX Error: #{textStatus}"

    success: (data, textStatus, jqXHR) ->
      console.log "CREATE measurements  Successful AJAX call"
      console.log data

@new_measurement_submit_handler = (event) ->
  event.preventDefault()
  values = $("#new-measurement-form").serialize()
  $.ajax '/measurements',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE activity AJAX Error: #{textStatus}"

    success: (data, textStatus, jqXHR) ->
      console.log "CREATE measurements  Successful AJAX call"
      console.log data
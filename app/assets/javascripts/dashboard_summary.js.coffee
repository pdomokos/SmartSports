@update_summary = (is_mobile) ->
  self = this
  chart_element = "dashboard-summary-container"
  today = new Date(Date.now())
  $.ajax '/users/'+$("#current-user-id")[0].value+"/outline",
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call"

      self.nodata = false
      if not data['profile']
        self.nodata = true
      else

        $("#"+chart_element+" div.chart-date").html(fmt_words(today))
        sum_steps = data['steps']
        $("#"+chart_element+" div.steps").html(sum_steps)
        percent = (sum_steps/10000.0*100.0).toFixed(1)
        $("#"+chart_element+" div.avg-percent").html(percent+"%")

        draw_percent(chart_element, percent)

        $("#"+chart_element+" div.avg-description").html("of 10,000 steps")
        $("#"+chart_element+" div.km-running").html((data['running']/1000).toFixed(2))
        $("#"+chart_element+" div.km-cycling").html((data['cycling']/1000).toFixed(2))
        $("#"+chart_element+" div.calories").html(Math.round(data['calories']))
        $("#"+chart_element+" div.distance").html((data['distance']/1000).toFixed(2))
        duration_sec = data['activity']
        timestr = get_hour(duration_sec)+"h "+get_min(duration_sec)+"min"
        $("#"+chart_element+" div.duration").html(timestr)

      draw_daily_activity(chart_element, data['profile'], is_mobile)

draw_daily_activity = (chart_element, data, is_mobile) ->
  self = this
  margin = {top: 30, right: 30, bottom: 30, left: 30}
  aspect = 400/700

  parent_width = $("#"+chart_element).parent().width()
  console.log "parent.width = "+parent_width
  width = parent_width-margin.left-margin.right
  height = aspect*width-margin.top-margin.bottom

  svg = d3.select($("#"+chart_element+" svg.activity-chart-svg")[0])
  svg = svg
    .attr("width", parent_width)
    .attr("height", height+margin.top+margin.bottom)
    .append("g")
    .attr("transform", "translate("+margin.left+","+margin.top+")")

  if self.nodata
    svg.append("text")
      .text("No data")
      .attr("class", "warn")
      .attr("x", width/2-margin.left)
      .attr("y", height/2)
    return

  time_extent = d3.extent(data, (d) -> d.time)
  time_extent[0] = 0
  time_scale = d3.scale.linear().domain(time_extent).range([0, width])

  y_extent = d3.extent( data, (d) -> d.activity )
  y_scale = d3.scale.linear().domain(y_extent).range([height, 0])

  time_axis = d3.svg.axis()
    .scale(time_scale)

  svg
    .append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0 ,"+height+")")
    .call(time_axis)
  svg
    .select(".x.axis")
    .append("text")
    .text("Hour")
    .attr("x", (width / 2) - margin.right)
    .attr("y", margin.bottom / 1.1)

  barwidth = width/49.0
  svg
    .selectAll("rect.act")
    .data(data)
    .enter()
      .append("rect")
      .attr("class", "act")
      .attr("x", (d) -> time_scale(d.time)-barwidth/2)
      .attr("y", (d) -> y_scale( d.activity) )
      .attr("width", (d) -> barwidth)
      .attr("height", (d) -> height - y_scale(  d.activity ) )

  if not is_mobile
    y_axis = d3.svg.axis()
      .scale(y_scale)
      .orient("left")
    svg
      .append("g")
      .attr("class", "y axis steps")
      .attr("transform", "translate(0, 0)")
      .call(y_axis)
    svg.select(".y.axis")
      .append("text")
      .text("Activity (Steps)")
      .attr("x", -30)
      .attr("y", -10)
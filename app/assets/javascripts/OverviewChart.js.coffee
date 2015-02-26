
class OverviewChart
  constructor: (@connection, @chart_element, @data, @data_helper) ->

  draw: (date, meas) ->
    self = this
    date_ymd = fmt(date)
    console.log "draw_trend_chart "+date_ymd+" -> "+meas

    margin = {top: 10, right: 30, bottom: 40, left: 50}
    aspect = 150/700
    width = $("#"+@chart_element).parent().width()-margin.left-margin.right
    self.height = aspect*width-margin.top-margin.bottom

    showdata = @data.walking
    y_domain_getter = (d) -> d.steps
    if meas!="walking"
      showdata = @data[meas]
      y_domain_getter = (d) -> d.distance

    if not showdata or showdata.length==0
      console.log "trends no data"
      @nodata = true
    else
      @nodata = false

    svg = d3.select($("#"+@chart_element+" svg.activity-trend-svg")[0])
    svg = svg
    .attr("width", width+margin.left+margin.right)
    .attr("height", self.height+margin.top+margin.bottom)
    .append("g")
    .attr("transform", "translate("+margin.left+","+margin.top+")")

    if @nodata
      svg.append("text")
      .text("No data")
      .attr("class", "warn")
      .attr("x", width/2-margin.left)
      .attr("y", self.height/2)


    walking = if @data.walking then @data.walking else []
    cycling = if @data.cycling then @data.cycling else []
    running = if @data.running then @data.running else []

    @time_extent = d3.extent(walking.concat(running.concat(cycling)), (d) -> Date.parse(d.date))

    @time_scale = d3.time.scale().domain(@time_extent).range([0, width])
    x_getter = (d) -> return(self.time_scale(Date.parse(d.date)))

    y_extent = d3.extent( showdata,  y_domain_getter )
    y_extent[0] = 0
    y_extent[1] = y_extent[1]*1.1

    y_scale = d3.scale.linear().domain(y_extent).range([self.height, 0])
    y_getter = (d) -> return(y_scale(y_domain_getter(d)))

    area = d3.svg
      .area()
      .interpolate("monotone")
      .x(x_getter)
      .y0(self.height)
      .y1(y_getter)

    line = d3.svg
      .line()
      .x(x_getter)
      .y(y_getter)


    time_axis = d3.svg.axis()
      .scale(self.time_scale)
      .ticks(d3.time.weeks, 2)
    svg
      .append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0 ,"+self.height+")")
      .call(time_axis)

    y_axis = d3.svg.axis()
      .scale(y_scale)
      .orient("left")
      .ticks(2)
    svg
      .append("g")
      .attr("class", "y axis")
      .attr()
      .call(y_axis)

    svg.
      select(".x.axis")
      .append("text")
      .text("Date")
      .attr("x", (width / 2) )
      .attr("y", margin.bottom*.8);

    svg.
      selectAll("#"+@chart_element+" svg.activity-trend-svg")
      .data(showdata)
      .enter()
      .append("circle")
      .attr("cx", (d) -> self.time_scale(Date.parse(d.date)))
      .attr("cy", y_getter)
      .attr("r", 3)

    svg.append("path")
      .attr("class", "line")
      .attr("clip-path", "url(#clip)")
      .attr("d", line(showdata));

  show_curr_week: (currdate) ->
    self = this
    monday = get_monday(fmt(currdate))
    monday.setHours(0)
    monday.setMinutes(0)
    monday.setSeconds(0)
    sunday = get_sunday(fmt(currdate))
    sunday.setHours(23)
    sunday.setMinutes(59)
    sunday.setSeconds(59)
    if sunday.getTime() > @time_extent[1]
      sunday = new Date(@time_extent[1])

    svg_trend = d3.select($("#"+@chart_element+" svg.activity-trend-svg g:first-child")[0])
    d3.selectAll($("#"+@chart_element+" svg.activity-trend-svg rect.sel")).remove()
    w = self.time_scale(sunday.getTime())-self.time_scale(monday.getTime())
    if w < 2
      w = 2
    svg_trend.insert("svg:rect", ":first-child")
      .attr("class", "sel")
      .attr("x", (self.time_scale(monday.getTime())))
      .attr("width", w)
      .attr("y", 0)
      .attr("height", self.height)

window.OverviewChart = OverviewChart

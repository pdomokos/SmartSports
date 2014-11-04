#= require BaseChart

class TrendChart extends BaseChart
  constructor: (@chart_element, data, @data_helper) ->
    super(data)
    console.log "constructing trend chart..."

  draw: (date, meas) ->
    self = this
    date_ymd = @fmt(date)
    console.log "draw_trend_chart "+date_ymd+" -> "+meas

    margin = {top: 10, right: 30, bottom: 40, left: 50}
    aspect = 150/700
    width = $("#"+@chart_element).parent().width()-margin.left-margin.right
    self.height = aspect*width-margin.top-margin.bottom

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
    .attr("width", width+margin.left+margin.right)
    .attr("height", self.height+margin.top+margin.bottom)
    .append("g")
    .attr("transform", "translate("+margin.left+","+margin.top+")")

    if showdata.length==0
      console.log "trends no data"
      svg.append("text")
      .text("No data!")
      .attr("class", "warn")
      .attr("x", width/2-margin.left)
      .attr("y", self.height/2)


    walking = @data.walking
    cycling = @data.cycling
    running = @data.running

    @time_extent = d3.extent(walking.concat(running.concat(cycling)), (d) -> Date.parse(d.date))
    console.log @time_extent
    console.log new Date(@time_extent[0]) + " !-! " + new Date(@time_extent[1])

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
      .interpolate("monotone")
      .x(x_getter)
      .y(y_getter)

    #  svg.append("clipPath")
    #    .attr("id", "clip")
    #    .append("rect")
    #    .attr("width", width)
    #    .attr("height", trend_height);

    svg.
      selectAll("circle")
      .data(showdata)
      .enter()
      .append("circle")
      .attr("cx", (d) -> self.time_scale(Date.parse(d.date)))
      .attr("cy", y_getter)
      .attr("r", 3)

    svg.append("path")
      .attr("class", "area")
      .attr("clip-path", "url(#clip)")
      .attr("d", area(showdata));

    svg.append("path")
      .attr("class", "line")
      .attr("clip-path", "url(#clip)")
      .attr("d", line(showdata));


    time_axis = d3.svg.axis()
      .scale(self.time_scale)
      .ticks(6)
      .tickSize(5, 0)
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

  show_curr_week: (currdate) ->
    self = this
    monday = @data_helper.get_monday(@fmt(currdate))
    monday.setHours(0)
    monday.setMinutes(0)
    monday.setSeconds(0)
    sunday = @data_helper.get_sunday(@fmt(currdate))
    sunday.setHours(23)
    sunday.setMinutes(59)
    sunday.setSeconds(59)
    console.log new Date(@time_extent[0]) + " <-> " + new Date(@time_extent[1])
    console.log monday + " - " + sunday
    if sunday.getTime() > @time_extent[1]
      sunday = new Date(@time_extent[1])

    console.log monday + " - " + sunday
    svg_trend = d3.select($("#moves-trend-svg g:first-child")[0])
    d3.selectAll($("#moves-trend-svg rect.sel")).remove()
    svg_trend.append("svg:rect")
      .attr("class", "sel")
      .attr("x", (self.time_scale(monday.getTime())))
      .attr("width", self.time_scale(sunday.getTime())-self.time_scale(monday.getTime()))
      .attr("y", 0)
      .attr("height", self.height)

window.TrendChart = TrendChart

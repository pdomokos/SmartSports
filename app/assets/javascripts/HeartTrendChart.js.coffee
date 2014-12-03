#= require BaseChart

class HeartTrendChart extends BaseChart
  constructor: (@connection, @chart_element, data) ->
    super(data)
    console.log "HeartTrendChart"
    @base_r = 3
    @selected_r = 8

    @margin = {top: 20, right: 40, bottom: 20, left: 40}
    aspect = 200/700
    @width = $("#"+@chart_element+"-container").parent().width()-@margin.left-@margin.right
    @height = aspect*@width-@margin.top-@margin.bottom
    @preprocess()

  preprocess: () ->
    console.log "preprocess"
    console.log "data size = "+@data.length.toString()
    console.log @data[64]

    daily = Object()
    for d in @data
      key = @fmt(new Date(Date.parse(d.date)))
      if daily[key]
        daily[key].push(d)
      else
        daily[key] = [d]

    @series = @get_series_avg(daily, ["diastolicbp", "systolicbp", "pulse"])
#    console.log @series
    @draw()

  get_series_avg: (data, columns) ->
    result = Object()
    for col in columns
      result[col] = []

    days = Object.keys(data)
    if not days
      return null
    days.sort()
    for day in days
      for col in columns
        daily_data = data[day]
        avg_value = @get_avg(daily_data, col)
        if(avg_value)
          result[col].push({'date': day, 'value': avg_value})
    return(result)

  get_avg: (data, column) ->
    sum = 0
    len = 0
    for d in data
      if d[column]
        sum = sum + d[column]
        len = len + 1
    if len==0
      return null
    else
      return sum/len

  draw: (date) ->
    self = this



    svg = d3.select($("#"+@chart_element+"-container svg."+@chart_element+"-chart-svg")[0])
    svg = svg
      .attr("width", self.width+self.margin.left+self.margin.right)
      .attr("height", self.height+self.margin.top+self.margin.bottom)
      .append("g")
      .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")

    data_sys = @series['systolicbp']
    console.log data_sys
    data_dia = @series['diastolicbp']
    data_hr = @series['pulse']
    time_extent = d3.extent(data_sys, (d) -> new Date(d.date))
    time_scale = d3.time.scale().domain(time_extent).range([0, self.width])

    y_extent = d3.extent(data_sys, (d) -> d.value)
    y_extent[0] = 50
    y_scale = d3.scale.linear().range([self.height - self.margin.bottom, self.margin.top]).domain(y_extent)

    hr_extent = d3.extent(data_hr, (d) -> d.value)
    hr_extent[0] = 50
    hr_scale = d3.scale.linear().range([self.height - self.margin.bottom, self.margin.top]).domain(hr_extent)

    console.log 'y_extent: ' + y_extent

    line = d3.svg.line()
      .x( (d) -> return(time_scale(new Date(d.date))))
      .y( (d) -> return(y_scale(d.value)))

    line_hr = d3.svg.line()
    .x( (d) -> return(time_scale(new Date(d.date))))
    .y( (d) -> return(hr_scale(d.value)))

    time_axis = d3.svg.axis()
      .scale(time_scale)
      .ticks(5)
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + (self.height-self.margin.top) + ")")
      .call(time_axis)
    svg.select(".x.axis")
      .append("text")
      .text("Date")
      .attr("x", (self.width / 2) - self.margin.left)
      .attr("y", self.margin.bottom+self.margin.top)

    y_axis = d3.svg.axis().scale(y_scale).orient("left")
    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate( 0, 0 )")
      .attr("stroke-width", "0")
      .call(y_axis)
    svg.select(".y.axis")
      .append("text")
      .text("mmHg")
      .attr("transform", "translate(-20, 0)")

    hr_axis = d3.svg.axis().scale(hr_scale).orient("right")
    svg.append("g")
      .attr("class", "hr axis")
      .attr("transform", "translate( "+@width.toString()+", 0 )")
      .attr("stroke-width", "0")
      .call(hr_axis)
    svg.select(".hr.axis")
      .append("text")
      .text("1/min")
      .attr("transform", "translate(-20, 0)")


    svg.selectAll("circle.sysavg")
      .data(data_sys)
      .enter()
      .append("circle")
      .attr("cx", (d) -> time_scale(new Date(d.date)))
      .attr("cy", (d) -> y_scale(d.value))
      .attr("r", @base_r)
      .attr("class", "sysavg")

    svg.append("path")
      .datum(data_sys)
      .attr("class", "line sysavg")
      .attr("d", line);

    svg.selectAll("circle.diaavg")
      .data(data_dia)
      .enter()
      .append("circle")
      .attr("cx", (d) -> time_scale(new Date(d.date)))
      .attr("cy", (d) -> y_scale(d.value))
      .attr("r", @base_r)
      .attr("class", "diaavg")

    svg.append("path")
      .datum(data_dia)
      .attr("class", "line diaavg")
      .attr("d", line);

    svg.selectAll("circle.hravg")
      .data(data_hr)
      .enter()
      .append("circle")
      .attr("cx", (d) -> time_scale(new Date(d.date)))
      .attr("cy", (d) -> hr_scale(d.value))
      .attr("r", @base_r)
      .attr("class", "hravg")

    svg.append("path")
      .datum(data_hr)
      .attr("class", "line hravg")
      .attr("d", line_hr);

window.HeartTrendChart = HeartTrendChart
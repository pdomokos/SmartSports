
class RRChart
  constructor: (@chart_element, rrdata, hrdata, crdata, speed_data) ->
    @base_r = 6
    @selected_r = 9
    @lines = []
    @charts = []
    @svg = []
    @data = []
    @y_scales = []
    @zoom = null
    @axisText = []
    @n = 0
    @y_axis = []

    axisAll = ['ms', '1/min', 'r/min', 'km/h']
    if rrdata
      @data.push(rrdata)
      @axisText[@n] = axisAll[0]
      @n+=1
    if hrdata
      @data.push(hrdata)
      @axisText[@n] = axisAll[1]
      @n+=1
    if crdata
      @data.push(crdata)
      @axisText[@n] = axisAll[2]
      @n+=1
    if speed_data
      @axisText[@n] = axisAll[3]
      @n+=1
      @data.push(speed_data)

    this.clear()

  draw: () ->
    self = this
    @zoom = d3.behavior.zoom()
      .on("zoom", self.do_zoom)

    chart_aspect = 1.3
    @margin = {top: 20, right: 30, bottom: 20, left: 40}
    @aspect = chart_aspect*@n/7.0

    @width = $("#"+@chart_element+"-container").width()
    @height = @aspect*@width
    @chart_height = chart_aspect/7.0*@width

    @svg = d3.select($("#"+@chart_element+"-container svg."+@chart_element+"-chart-svg")[0])
    @svg
      .attr("width", self.width)
      .attr("height", self.height)

    @svg.append("defs").append("clipPath")
      .attr("id", "clip-pane")
      .append("rect")
        .attr("class", "pane")
        .attr("width", self.width-self.margin.left)
        .attr("height", self.height)

    time_extent = d3.extent(@data[0], (d) -> new Date(d.time))
    @time_scale = d3.time.scale().domain(time_extent).range([0, self.width-self.margin.left-self.margin.right])
    for i in [0..@n-1]
      ch = @svg
        .append("g")
        .attr("transform", "translate(0,"+(1.0*i*self.chart_height)+")")

      @charts.push(ch)

      sum_fn = (s, a) ->
        s+a.value
      avg = @data[i].reduce( sum_fn , 0)/@data[i].length

      @data[i] = @data[i].filter( (x) ->
        x.value<2*avg
      )
      console.log "avg="+avg.toFixed(2)

      y_extent = d3.extent(self.data[i].filter( (d) ->
        return d.value>0
      ), (d) -> d.value)
      console.log y_extent
      y_scale = d3.scale.linear().range([(self.chart_height - self.margin.bottom- self.margin.top), 0]).domain(y_extent)
      @y_scales.push(y_scale)

      fn = self.draw_plot(i)
      @lines.push(fn)

      @y_axis.push(null)

    @zoom.x(self.time_scale)
    @svg
      .call(self.zoom)
      .call(self.zoom.event)

  do_zoom: () =>
    self = this

    for j in [0..(self.n-1)]
      visibleData = self.data[j].filter( (d) ->
        dt = self.time_scale(new Date(d.time))
        return dt>0 && dt<self.width && d.value>0
      )
      #if visibleData.length < 30
      #  console.log(visibleData)
      currExtent = d3.extent(visibleData, (d) -> d.value )
      self.y_scales[j].domain(currExtent).nice()
      self.charts[j].select("path.line").attr("d", self.lines[j](self.data[j]))

      self.charts[j].select("g.x.axis").call(self.time_axis)
      self.charts[j].select("g.y.axis").call(self.y_axis[j])

  draw_plot: (i) -> #chart, data, yAxisText="ms") ->
    self = this
    console.log "draw_plot called "+i.toString()
    currdata = @data[i]

    @time_axis = d3.svg.axis()
      .scale(@time_scale)
      .ticks(10)

    rrline = d3.svg.line()
      .x( (d) -> return(self.time_scale(new Date(d.time))))
      .defined((d) -> return(d.value!=0))
      .y( (d) -> return(self.y_scales[i](d.value)))
      .interpolate("linear")

    canvas = @charts[i]
      .append("g")
      .attr("transform", "translate("+self.margin.left+","+(self.margin.top)+")")
      .attr("clip-path", "url(#clip-pane)")

    @charts[i].append("g")
      .attr("class", "x axis")
      .attr("transform", "translate("+self.margin.left+","+(self.chart_height-self.margin.bottom)+")")
      .call(@time_axis)

    @y_axis[i] = d3.svg.axis().scale(self.y_scales[i]).orient("left").ticks(7)
    @charts[i].append("g")
      .attr("class", "y axis")
      .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")
      .attr("stroke-width", "0")
      .call(self.y_axis[i])
      .append("text")
      .text(@axisText[i])

    canvas.append("path")
      .attr("class", "line rr")
      .attr("d", rrline(currdata))

    return(rrline)

  clear: () ->
    $("svg."+@chart_element+"-chart-svg").html("")

window.RRChart = RRChart

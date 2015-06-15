
class RRChart
  constructor: (@chart_element, rrdata, hrdata, crdata, speed_data) ->
    @base_r = 6
    @selected_r = 9
    @lines = []
    @charts = []
    @svg = []
    @data = []
    @y_extent= []
    @y_scale = []
    @axisText = []
    @n = 0

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

      y_extent = d3.extent(@data[i], (d) -> d.value)
      @y_extent.push(y_extent)
      y_scale = d3.scale.linear().range([self.chart_height - self.margin.bottom- self.margin.top, 0]).domain(@y_extent[i])
      @y_scale.push(y_scale)


    time_extent = d3.extent(@data[0], (d) -> new Date(d.time))
    @time_scale = d3.time.scale().domain(time_extent).range([0, self.width-self.margin.left-self.margin.right])
    @time_axis = d3.svg.axis()
      .scale(@time_scale)
      .ticks(10)

    for i in [0..(@n-1)]
      z = self.draw_plot(i)
      @lines.push(z)

    zoom = d3.behavior.zoom()
      .on("zoom", self.do_zoom)

    @svg
      .call(zoom)

    zoom.x(@time_scale)

  do_zoom: () =>
    self = this
    console.log "do_zoom"
    console.log self.lines
    @svg.select("g.x.axis").call(@time_axis)
    for j in [0..(self.n-1)]
      self.charts[j].select("path.line").attr("d", self.lines[j](self.data[j]))

  clear: () ->
    $("svg."+@chart_element+"-chart-svg").html("")

  draw_plot: (i) -> #chart, data, yAxisText="ms") ->
    self = this

    rrline = d3.svg.line()
      .x( (d) -> return(self.time_scale(new Date(d.time))))
      .y( (d) -> return(self.y_scale[i](d.value)))

    canvas = @charts[i]
      .append("g")
      .attr("transform", "translate("+self.margin.left+","+(self.margin.top)+")")
      .attr("clip-path", "url(#clip-pane)")


    @charts[i].append("g")
      .attr("class", "x axis")
      .attr("transform", "translate("+self.margin.left+","+(self.chart_height-self.margin.bottom)+")")
      .call(self.time_axis)

    y_axis = d3.svg.axis().scale(self.y_scale[i]).orient("left").ticks(7)
    @charts[i].append("g")
      .attr("class", "y axis")
      .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")
      .attr("stroke-width", "0")
      .call(y_axis)
      .append("text")
      .text(@axisText[i])

    canvas.append("path")
      .attr("class", "line rr")
      .attr("d", rrline(self.data[i]))

    return(rrline)

window.RRChart = RRChart

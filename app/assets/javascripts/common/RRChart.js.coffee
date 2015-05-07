
class RRChart
  constructor: (@chart_element, @data, @hrdata, @crdata) ->
    @base_r = 6
    @selected_r = 9
    this.clear()

  draw: () ->
    self = this

    @margin = {top: 20, right: 30, bottom: 20, left: 40}
    @aspect = 1.5/7.0

    @width = $("#"+@chart_element+"-container").width()
    @height = @aspect*@width

    total_height = @height
    if @crdata
      total_height *= 3
    else
      total_height *= 2

    console.log "dimensions: "+@width+" x "+total_height
    @svg = d3.select($("#"+@chart_element+"-container svg."+@chart_element+"-chart-svg")[0])
    @svg
      .attr("width", self.width)
      .attr("height", total_height)

    chart1 = @svg
      .append("g")
    chart2 = @svg
      .append("g")
      .attr("transform", "translate(0,"+(self.height)+")")
    chart3 = null
    if @crdata
      console.log "display crdata"
      chart3 = @svg
        .append("g")
        .attr("transform", "translate(0,"+(2*self.height)+")")

    self.draw_plot(chart1, @data)
    self.draw_plot(chart2, @hrdata, "1/min")
    if @crdata
      self.draw_plot(chart3, @crdata, "r/min")

  clear: () ->
    $("svg."+@chart_element+"-chart-svg").html("")

  draw_plot: (chart, data, yAxisText="ms") ->
    self = this
    time_extent = d3.extent(data, (d) -> new Date(d.time))
    time_scale = d3.time.scale().domain(time_extent).range([0, self.width-self.margin.left-self.margin.right])

    y_extent = d3.extent(data, (d) -> d.value)
    y_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(y_extent)

    rrline = d3.svg.line()
      .x( (d) -> return(time_scale(new Date(d.time))))
      .y( (d) -> return(y_scale(d.value)))

    canvas = chart
      .append("g")
      .attr("transform", "translate("+self.margin.left+","+(self.margin.top)+")")

    time_axis = d3.svg.axis()
      .scale(time_scale)
      .ticks(10)

    chart.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate("+self.margin.left+","+(self.height-self.margin.bottom)+")")
      .call(time_axis)

    y_axis = d3.svg.axis().scale(y_scale).orient("left")
    chart.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")
      .attr("stroke-width", "0")
      .call(y_axis)
      .append("text")
      .text(yAxisText)

    canvas.append("path")
      .attr("class", "line rr")
      .attr("d", rrline(data))



tmp: () ->
    time_extent = d3.extent(@data, (d) -> new Date(d.date))
    time_scale = d3.time.scale().domain(time_extent).range([0, self.width-self.margin.left-self.margin.right])

    y_extent = d3.extent(@data, (d) -> d.systolicbp)
    y_extent[0] = 50
    y_extent[1] = Math.max(y_extent[1], 150)
    y_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(y_extent)

    ldata = @create_lines(y_extent)
    canvas.selectAll("line")
    .data(ldata)
    .enter()
    .append("svg:line")
    .attr("x1", time_scale(time_extent[0]))
    .attr("y1", (d) -> y_scale(d.x))
    .attr("x2", time_scale(time_extent[1]))
    .attr("y2", (d) -> y_scale(d.x))
    .attr("stroke", (d) -> d.color)
    .attr("stroke-width", 1)
    .attr("opacity", 1)

    time_axis = d3.svg.axis()
    .scale(time_scale)
    .ticks(5)

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate("+self.margin.left+","+(self.height-self.margin.bottom)+")")
      .call(time_axis)

    y_axis = d3.svg.axis().scale(y_scale).orient("left")
    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")
      .attr("stroke-width", "0")
      .call(y_axis)
      .append("text")
      .text("mmHg")


    @nodata = false
    if @data.length ==0
      @nodata = true

    if @nodata
      svg.append("text")
      .text("No data")
      .attr("class", "warn")
      .attr("x", self.width/2-self.margin.left)
      .attr("y", self.height/2)
      return

    svg.select(".x.axis")
      .append("text")
      .text("Date")
      .attr("x", (self.width / 2) - self.margin.left)
      .attr("y", self.margin.bottom+self.margin.top)


    hr_extent = d3.extent(@data, (d) -> d.pulse)
    hr_extent[0] = Math.min(hr_extent[0], 50)
    hr_extent[1] = Math.max(hr_extent[1], 200)
    hr_range = hr_extent[1]-hr_extent[0]

    classfn = (d) -> "colset9_"+Math.round(1.0*(d.pulse-hr_extent[0])/hr_range*7.0).toString()

    canvas.selectAll("circle.sys")
    .data(@data)
    .enter()
    .append("circle")
    .attr("cx", (d) -> time_scale(new Date(d.date)))
    .attr("cy", (d) -> y_scale(d.systolicbp))
    .attr("r", @base_r)
    .attr("class", (d) -> "sys "+classfn(d))
    .attr("id", (d) -> "sys-"+d.data_id.toString())
    .on("mouseover", (d) ->
      if d.systolicbp
        $("#"+self.chart_element+"-container").find("div.selected-meas").html(d.systolicbp.toString()+"/"+d.diastolicbp.toString()+" "+d.pulse.toString())
      d3.select(this)
      .transition()
      .attr("r", self.selected_r)
      d3.select(this).classed("selected", true)
      id = this.id.toString().substr(4)
      d3.select("circle#dia-"+id)
      .transition()
      .attr("r", self.selected_r)
      d3.select("circle#dia-"+id).classed("selected", true)
      d3.select("line#press-"+id)
      .transition()
      .style("stroke-width", 4)
      d3.select("line#press-"+id).classed("selected", true)
    )
    .on("mouseout", (d) ->
      $("#"+self.chart_element+"-container").find("div.selected-meas").html("")
      d3.select(this)
      .transition()
      .attr("r", self.base_r)
      d3.select(this).classed("selected", false)
      id = this.id.toString().substr(4)
      d3.select("circle#dia-"+id)
      .transition()
      .attr("r", self.base_r)
      d3.select("circle#dia-"+id).classed("selected", false)
      d3.select("line#press-"+id)
      .transition()
      .style("stroke-width", 2)
      d3.select("line#press-"+id).classed("selected", false)
    )

    canvas.selectAll("circle.dia")
    .data(@data)
    .enter()
    .append("circle")
    .attr("cx", (d) -> time_scale(new Date(d.date)))
    .attr("cy", (d) -> y_scale(d.diastolicbp))
    .attr("r", self.base_r)
    .attr("class", (d) -> "dia "+classfn(d))
    .attr("id", (d) -> "dia-"+d.data_id.toString())
    .on("mouseover", (d) ->
      if d.systolicbp
        $("#"+self.chart_element+"-container").find("div.selected-meas").html(d.systolicbp.toString()+"/"+d.diastolicbp.toString()+" "+d.pulse.toString())
      d3.select(this)
      .transition()
      .attr("r", self.selected_r)
      d3.select(this).classed("selected", true)
      id = this.id.toString().substr(4)
      d3.select("circle#sys-"+id)
      .transition()
      .attr("r", self.selected_r)
      d3.select("circle#sys-"+id).classed("selected", true)
      d3.select("line#press-"+id)
      .transition()
      .style("stroke-width", 4)
      d3.select("line#press-"+id).classed("selected", true)
    )
    .on("mouseout", (d) ->
      $("#"+self.chart_element+"-container").find("div.selected-meas").html("")
      d3.select(this)
      .transition()
      .attr("r", self.base_r)
      d3.select(this).classed("selected", false)
      id = this.id.toString().substr(4)
      d3.select("circle#sys-"+id)
      .transition()
      .attr("r", self.base_r)
      d3.select("circle#sys-"+id).classed("selected", false)
      d3.select("line#press-"+id)
      .transition()
      .style("stroke-width", 2)
      d3.select("line#press-"+id).classed("selected", false)
    )

    canvas.selectAll("line.press")
    .data(@data)
    .enter()
    .append("line")
    .attr("x1", (d) -> time_scale(new Date(d.date)))
    .attr("y1", (d) -> y_scale(d.diastolicbp))
    .attr("x2", (d) -> time_scale(new Date(d.date)))
    .attr("y2", (d) -> y_scale(d.systolicbp))
    .attr("stroke-width", 2)
    .attr("class", (d) -> "press "+classfn(d))
    .attr("id", (d) -> "press-"+d.data_id.toString())



  create_lines:  (r) ->
    start = r[0] - r[0] % 5
    end = r[1] - r[1] % 5
    i = start
    ret = []
    while i <= end
      col = '#e0e0e0'
      if i % 25 == 0
        col = '#c0c0c0'
      ret.push({x: i, color: col})
      i += 5
    return ret

window.RRChart = RRChart

#= require BaseChart

class HealthChart
  constructor: (@connection, @chart_element, @data) ->
    i = 0
    for d in @data
      d.data_id = i
      i = i+1
    @time_scale = null
    @callback = null
    @base_r = 6
    @selected_r = 9

  draw: (date) ->
    self = this
    date_ymd = fmt(date)

    @margin = {top: 20, right: 30, bottom: 20, left: 40}
    aspect = 400/700
    @width = $("#"+@chart_element+"-container").parent().width()-@margin.left-@margin.right
    @height = aspect*@width-@margin.top-@margin.bottom

    svg = d3.select($("#"+@chart_element+"-container svg."+@chart_element+"-chart-svg")[0])
    svg = svg
      .attr("width", self.width+self.margin.left+self.margin.right)
      .attr("height", self.height+self.margin.top+self.margin.bottom)
      .append("g")
      .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")

    time_extent = d3.extent(@data, (d) -> new Date(d.date))
    time_scale = d3.time.scale().domain(time_extent).range([0, self.width])

    y_extent = d3.extent(@data, (d) -> d.systolicbp)
    y_extent[0] = 50
    y_extent[1] = Math.max(y_extent[1], 175)
    y_scale = d3.scale.linear().range([self.height - self.margin.bottom, self.margin.top]).domain(y_extent)

    ldata = @create_lines(y_extent)
    svg.selectAll("line")
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

    hr_extent = d3.extent(@data, (d) -> d.pulse)
    hr_extent[0] = Math.min(hr_extent[0], 50)
    hr_extent[1] = Math.max(hr_extent[1], 200)
    hr_range = hr_extent[1]-hr_extent[0]

    classfn = (d) -> "colset9_"+Math.round(1.0*(d.pulse-hr_extent[0])/hr_range*7.0).toString()

    svg.selectAll("circle.sys")
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

    svg.selectAll("circle.dia")
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

    svg.selectAll("line.press")
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

window.HealthChart = HealthChart

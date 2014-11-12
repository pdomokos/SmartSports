#= require BaseChart

class HealthChart extends BaseChart
  constructor: (@connection, @chart_element_hr, @chart_element_bp, @chart_element_spo2, data, @data_helper) ->
    super(data)
    i = 0
    for d in @data
      d.data_id = i
      i = i+1
    @time_scale = null
    @callback = null

  draw: (date) ->
    self = this
    date_ymd = @fmt(date)
    console.log "draw_health_chart ["+@chart_element_hr+"] " +date_ymd

    @margin = {top: 20, right: 30, bottom: 20, left: 30}
    aspect = 400/700
    @width = $("#"+@chart_element_hr+"-container").parent().width()-@margin.left-@margin.right
    @height = aspect*@width-@margin.top-@margin.bottom
    console.log "width="+@width+" height="+@height

    @draw_hr(date)
    @draw_bp(date)
    @draw_spo2(date)

  draw_spo2: (date) ->
    self = this
    svg = d3.select($("#"+@chart_element_spo2+"-container svg."+@chart_element_spo2+"-chart-svg")[0])
    svg = svg
      .attr("width", self.width+self.margin.left+self.margin.right)
      .attr("height", self.height+self.margin.top+self.margin.bottom)
      .append("g")
      .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")

    showdata = []
    for item in @data
      if item.SPO2
        showdata.push(item)
    console.log showdata

    time_extent = d3.extent(showdata, (d) -> Date.parse(d.date))
    time_scale = d3.time.scale().domain(time_extent).range([0, self.width])

    y_extent = d3.extent(showdata, (d) -> d.SPO2)
    y_extent[0] = 90
    y_extent[1] = 100
    y_scale = d3.scale.linear().range([self.height - self.margin.bottom, self.margin.top]).domain(y_extent)

    area = d3.svg
      .area()
      .interpolate("monotone")
      .x((d) -> time_scale( Date.parse(d.date)))
      .y0(self.height)
      .y1((d) -> y_scale(d.SPO2))

    line = d3.svg
      .line()
      .interpolate("monotone")
      .x((d) -> time_scale(Date.parse(d.date)))
      .y((d) -> y_scale(d.SPO2))

    svg.append("path")
      .attr("class", "area")
      .attr("clip-path", "url(#clip)")
      .attr("d", area(showdata));

    svg.append("path")
      .attr("class", "line")
      .attr("clip-path", "url(#clip)")
      .attr("d", line(showdata));


  draw_bp: (date) ->
    self = this
    svg = d3.select($("#"+@chart_element_bp+"-container svg."+@chart_element_bp+"-chart-svg")[0])
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

    console.log 'y_extent: ' + y_extent

    ldata = @create_lines(y_extent)
    svg.selectAll("line")
      .data(ldata)
      .enter()
      .append("svg:line")
      .attr("x1", time_scale(time_extent[0]))
      .attr("y1", (d) ->
        y_scale(d.x))
      .attr("x2", time_scale(time_extent[1]))
      .attr("y2", (d) ->
        y_scale(d.x))
      .attr("stroke", (d) ->
        d.color)
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

    svg.selectAll("circle.sys")
      .data(@data)
      .enter()
      .append("circle")
      .attr("cx", (d) -> time_scale(new Date(d.date)))
      .attr("cy", (d) -> y_scale(d.systolicbp))
      .attr("r", 4)
      .attr("class", "sys")
      .attr("id", (d) -> "sys-"+d.data_id.toString())
      .on("mouseover", (d) ->
        $("#"+self.chart_element_hr+"-container").find("div.selected-meas").html(d.pulse)
        if d.systolicbp
          $("#"+self.chart_element_bp+"-container").find("div.selected-meas").html(d.systolicbp.toString()+"/"+d.diastolicbp.toString())
        d3.select(this)
        .transition()
        .attr("r", 8)
        .style("fill", '#ffac29' )
        id = this.id.toString().substr(4)
        d3.select("circle#hr-"+id)
        .transition()
        .attr("r", 8)
        .style("fill", '#ffac29' )
        d3.select("circle#dia-"+id)
        .transition()
        .attr("r", 8)
        .style("fill", '#ffac29' )
        d3.select("line#press-"+id)
        .transition()
        .attr("stroke-width", 4)
        .style("stroke", '#ffac29' )
      )
      .on("mouseout", (d) ->
        $("#"+self.chart_element_hr+"-container").find("div.selected-meas").html("")
        $("#"+self.chart_element_bp+"-container").find("div.selected-meas").html("")
        d3.select(this)
        .transition()
        .attr("r", 4)
        .style("fill", '#2FB5E9' )
        id = this.id.toString().substr(4)
        d3.select("circle#hr-"+id)
        .transition()
        .attr("r", 4)
        .style("fill", '#2FB5E9' )
        d3.select("circle#dia-"+id)
        .transition()
        .attr("r", 4)
        .style("fill", '#2FB5E9' )
        d3.select("line#press-"+id)
        .transition()
        .attr("stroke-width", 1)
        .style("stroke", '#2FB5E9' )
      )

    svg.selectAll("circle.dia")
      .data(@data)
      .enter()
      .append("circle")
      .attr("cx", (d) -> time_scale(new Date(d.date)))
      .attr("cy", (d) -> y_scale(d.diastolicbp))
      .attr("r", 4)
      .attr("class", "dia")
      .attr("id", (d) -> "dia-"+d.data_id.toString())

    svg.selectAll("line.press")
      .data(@data)
      .enter()
      .append("line")
      .attr("x1", (d) -> time_scale(new Date(d.date)))
      .attr("y1", (d) -> y_scale(d.diastolicbp))
      .attr("x2", (d) -> time_scale(new Date(d.date)))
      .attr("y2", (d) -> y_scale(d.systolicbp))
      .attr("stroke-width", 1)
      .attr("class", "press")
      .attr("id", (d) -> "press-"+d.data_id.toString())

  draw_hr: (date) ->
    self = this
    svg = d3.select($("#"+@chart_element_hr+"-container svg."+@chart_element_hr+"-chart-svg")[0])
    svg = svg
    .attr("width", self.width+self.margin.left+self.margin.right)
    .attr("height", self.height+self.margin.top+self.margin.bottom)
    .append("g")
    .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")

    time_extent = d3.extent(@data, (d) -> new Date(d.date))
    time_scale = d3.time.scale().domain(time_extent).range([0, self.width])

    y_extent = d3.extent(@data, (d) -> d.pulse)
    y_extent[0] = Math.min(y_extent[0], 50)
    y_extent[1] = Math.max(y_extent[1], 150)
    y_scale = d3.scale.linear().range([self.height - self.margin.bottom, self.margin.top]).domain(y_extent)

    console.log 'y_extent: ' + y_extent

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
      .text("Heart rate")
      .attr("transform", "translate(-20, 0)")

    svg.selectAll("circle.hr")
      .data(@data)
      .enter()
      .append("circle")
      .attr("cx", (d) -> time_scale(new Date(d.date)))
      .attr("cy", (d) -> y_scale(d.pulse))
      .attr("class", "hr")
      .attr("r", 4)
      .attr("id", (d) -> "hr-"+d.data_id.toString())
      .on("mouseover", (d) ->
        $("#"+self.chart_element_hr+"-container").find("div.selected-meas").html(d.pulse)
        if d.systolicbp
          $("#"+self.chart_element_bp+"-container").find("div.selected-meas").html(d.systolicbp.toString()+"/"+d.diastolicbp.toString())
        d3.select(this)
          .transition()
          .attr("r", 8)
          .style("fill", '#ffac29' )
        id = this.id.toString().substr(3)
        d3.select("circle#sys-"+id)
          .transition()
          .attr("r", 8)
          .style("fill", '#ffac29' )
        d3.select("circle#dia-"+id)
          .transition()
          .attr("r", 8)
          .style("fill", '#ffac29' )
        d3.select("line#press-"+id)
          .transition()
          .attr("stroke-width", 4)
          .style("stroke", '#ffac29' )
      )
      .on("mouseout", (d) ->
        $("#"+self.chart_element_hr+"-container").find("div.selected-meas").html("")
        $("#"+self.chart_element_bp+"-container").find("div.selected-meas").html("")
        d3.select(this)
          .transition()
          .attr("r", 4)
          .style("fill", '#2FB5E9' )
        id = this.id.toString().substr(3)
        d3.select("circle#sys-"+id)
          .transition()
          .attr("r", 4)
          .style("fill", '#2FB5E9' )
        d3.select("circle#dia-"+id)
          .transition()
          .attr("r", 4)
          .style("fill", '#2FB5E9' )
        d3.select("line#press-"+id)
          .transition()
          .attr("stroke-width", 1)
          .style("stroke", '#2FB5E9' )
      )


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

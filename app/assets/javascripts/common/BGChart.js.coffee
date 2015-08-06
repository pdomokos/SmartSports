class BGChart
  constructor: (@chart_element, @data, @aspect=2.0/7) ->

    console.log "Creating BGChart "+TrendChart.count

    @base_r = 4
    @selected_r = 8
    @preproc_cb = null

    # default, overwrite if axis labels need more place
    @margin = {top: 40, right: 40, bottom: 40, left: 40}

    @width = $("#"+@chart_element+"-container").parent().width()
    @height = @aspect*@width

    @n = @data.length

    @color_map = {}
    @color_map[48] = "bg1Point"
    @color_map[58] = "bg2Point"
    @color_map[60] = "bg3Point"
    @color_map[62] = "bg4Point"

    @cb_over = null
    @cb_out = null
    @cb_click = null

    @tick_unit = d3.time.week
    @ticks = 1
    # get_series() needs to be provided in subclass

  get_time_extent: () ->
    return d3.extent(@data, (d) -> new Date(d.date))

  get_value_extent: (keys) ->
    return d3.extent(@data, (d) -> d.blood_sugar)

  draw: (date) ->
    self = this


    if @preproc_cb != null
      @preproc_cb(@data)
    #console.log "draw bg data - "+@chart_element
    #window.series = @series

    svg = d3.select($("#"+@chart_element+"-container svg."+@chart_element+"-chart-svg")[0])
    svg
      .attr("width", self.width)
      .attr("height", self.height)

    #@add_legend()
    dlen = @data.length
    if @data == null or dlen == 0
      svg.append("text")
      .text("No data")
      .attr("class", "warn")
      .attr("x", self.width/2-self.margin.left)
      .attr("y", self.height/2)
      return

    time_extent = @get_time_extent()
    @time_scale = d3.time.scale().domain(time_extent).range([0, self.width-self.margin.left-self.margin.right])

    @value_extent = @get_value_extent()
    @scale_left = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(self.value_extent)

    @line = d3.svg.line()
      .x( (d) -> return(self.time_scale(new Date(d.date))))
      .y( (d) -> return(self.scale_left(d.blood_sugar)))

    time_axis = d3.svg.axis()
      .scale(self.time_scale)
      .ticks(self.tick_unit, self.ticks)

    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate("+self.margin.left+","+(self.height-self.margin.bottom)+")")
      .call(time_axis)

    y_axis_left = d3.svg.axis().scale(self.scale_left).orient("left")
    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate( "+self.margin.left+", "+self.margin.top+" )")
      .attr("stroke-width", "0")
      .call(y_axis_left)
      .append("text")
      .text("BG (mmol/L)")
      .attr("transform", "translate("+(-self.margin.left/2)+", "+(-self.margin.top/2)+")")


    canvas = svg.append("g")
    .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")

    #dd = self.series.filter( (d) -> d[k]!=null)
    if @data.length > 0
      canvas.append("path")
        .datum(self.data)
        .attr("class", "grayline")
        .attr("d", self.line)

      canvas.selectAll("circle.bg")
        .data(self.data)
        .enter()
        .append("circle")
        .attr("cx", (d) -> self.time_scale(new Date(d.date)))
        .attr("cy", (d) -> self.scale_left(d.blood_sugar))
        .attr("r", @base_r)
        .attr("class", (d) -> self.color_map[d.blood_sugar_time])
        .on("mouseover", (d) ->
          if self.cb_over
            self.cb_over(d, this)
        )
        .on("mouseout", (d) ->
          if self.cb_out
            self.cb_out(d, this)
        )
        .on("click", (d) ->
          if self.cb_click
            self.cb_click(d, this)
        )

  add_highlight: (from, to, style) ->
    self = this
    canvas = d3.select($("#"+@chart_element+"-container svg."+@chart_element+"-chart-svg g:last-child")[0])

    w = self.time_scale(new Date(to)) - self.time_scale(new Date(from))
    h = Math.abs(self.scale_left(self.value_extent[1])- self.scale_left(self.value_extent[0]))
    maxval = Math.max(self.value_extent[0], self.value_extent[1])
    canvas.insert("svg:rect", ":first-child")
      .attr("class", style)
      .attr("x", (self.time_scale(new Date(from))))
      .attr("width", w)
      .attr("y", self.scale_left(maxval)-self.margin.top)
      .attr("height", self.height- self.margin.bottom)

  add_legend: () ->
    self = this
    for k in @color_map.keys()
      new_label = $("#legend-template").children().first().clone()
      new_id =  "legend-labelSEP"+@chart_element+"SEP" + k
      new_label.attr('id', new_id)
      new_label.appendTo($("#"+@chart_element+"-container .legend-container"))
      $("#"+new_id).html(@name_map[k])
      $("#"+new_id).addClass(@color_map[k])

window.BGChart = BGChart

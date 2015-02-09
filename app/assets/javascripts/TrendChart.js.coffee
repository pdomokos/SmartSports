#= require BaseChart

class TrendChart
  constructor: (@chart_element, @data, @series_keys, series_names, @side_keys, series_colors, @labels, @zero_when_missing=false, @aspect=2.0/7) ->
    console.log "TrendChart"
    @base_r = 3
    @selected_r = 8
    @preproc_cb = null

    # default, overwrite if axis labels need more place
    @margin = {top: 40, right: 40, bottom: 40, left: 40}

    @width = $("#"+@chart_element+"-container").parent().width()
    @height = @aspect*@width

    @n = @series_keys.length
    @color_map = {}
    @name_map = {}
    @side_map = {}
    for i in [0..@n-1]
      @color_map[@series_keys[i]] = series_colors[i]
      @name_map[@series_keys[i]] = series_names[i]
      @side_map[@series_keys[i]] = @side_keys[i]

    @cb_over = null
    @cb_out = null
    @cb_click = null

  # get_series() needs to be provided in subclass

  get_time_extent: () ->
    return d3.extent(@series, (d) -> new Date(d.date))

  get_value_extent: (keys) ->
    ext = null
    for k in keys
      if ext == null
        newext = d3.extent(@series, (d) -> d[k])
        if not(newext[0]==null or newext[0] == undefined or newext[1]==null or newext[1]==undefined)
          ext = newext
      else
        newext = d3.extent(@series, (d) -> d[k])
        if not(newext[0]==null or newext[0] == undefined or newext[1]==null or newext[1]==undefined)
          ext = [Math.min(ext[0], newext[0]), Math.max(ext[1], newext[1])]
    return ext

  draw: (date) ->
    self = this
    hash = @get_series()

    @nodata = false
    hashkeys = Object.keys(hash)
    if hashkeys.length ==0
      @nodata = true

    hashkeys.sort()
    @series = hashkeys.map( (k) -> hash[k])

    if @preproc_cb != null
      @preproc_cb(@series)
    console.log "draw - series"
    #window.series = @series

    svg = d3.select($("#"+@chart_element+"-container svg."+@chart_element+"-chart-svg")[0])
    svg
      .attr("width", self.width)
      .attr("height", self.height)

    @add_legend()
    if @nodata
      svg.append("text")
      .text("No data")
      .attr("class", "warn")
      .attr("x", self.width/2-self.margin.left)
      .attr("y", self.height/2)
      return

    time_extent = @get_time_extent()
    time_scale = d3.time.scale().domain(time_extent).range([0, self.width-self.margin.left-self.margin.right])

    @line = {}
    @ext_map = {}
    @scale_map = {}

    left_keys = [0..@n-1].map( (i) ->
      if self.side_keys[i] == 'left'
        self.series_keys[i]
      else
        null).filter( (i) -> i!=null )

    right_keys = [0..@n-1].map( (i) ->
      if self.side_keys[i] == 'right'
        self.series_keys[i]
      else
        null).filter( (i) -> i!=null )

    ext_left = @get_value_extent(left_keys)
    scale_left = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(ext_left)

    has_right = right_keys.length>0
    if(has_right)
      ext_right = @get_value_extent( right_keys )
      scale_right = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(ext_right)

    if @zero_when_missing
      ext_left[0] = 0
      if(has_right)
        ext_right[0] = 0

    for k in @series_keys
      @ext_map[k] = ext_right
      @scale_map[k] = scale_right

      if @side_map[k] == 'left'
        @ext_map[k] = ext_left
        @scale_map[k] = scale_left

      @line[k] = d3.svg.line()
        .x( (d) -> return(time_scale(new Date(d.date))))
        .y( (d) -> return(self.scale_map[k](d[k])))

    time_axis = d3.svg.axis()
      .scale(time_scale)
      .ticks(d3.time.weeks, 1)
    svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate("+self.margin.left+","+(self.height-self.margin.bottom)+")")
      .call(time_axis)

    y_axis_left = d3.svg.axis().scale(scale_left).orient("left")
    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate( "+self.margin.left+", "+self.margin.top+" )")
      .attr("stroke-width", "0")
      .call(y_axis_left)
      .append("text")
      .text(self.labels[0])
      .attr("transform", "translate("+(-self.margin.left/2)+", "+(-self.margin.top/2)+")")

    if(has_right)
      y_axis_right = d3.svg.axis().scale(scale_right).orient("right")
      svg.append("g")
        .attr("class", "hr axis")
        .attr("transform", "translate( "+(self.width-self.margin.right)+", "+self.margin.top+" )")
        .attr("stroke-width", "0")
        .call(y_axis_right)
        .append("text")
        .text(self.labels[1])
        .attr("transform", "translate("+(-self.margin.right/2)+", "+(-self.margin.top/2)+" )")


    canvas = svg.append("g")
      .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")

    for k in @series_keys
      dd = self.series.filter( (d) -> d[k]!=null)
      if dd.length > 0
        canvas.selectAll("circle."+k+"-avg")
          .data(dd)
          .enter()
            .append("circle")
            .attr("cx", (d) -> time_scale(new Date(d.date)))
            .attr("cy", (d) -> self.scale_map[k](d[k]))
            .attr("r", @base_r)
            .attr("class", self.color_map[k]+" "+k)
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
        canvas.append("path")
          .datum(dd)
          .attr("class", "line "+self.color_map[k]+" "+k)
          .attr("d", self.line[k])

  add_legend: () ->
    self = this
    for k in @series_keys
      new_label = $("#legend-template").children().first().clone()
      tmp = @chart_element.replace("-", "_")
      new_id =  "legend-label_"+tmp+"-" + k
      new_label.attr('id', new_id)
      new_label.appendTo($("#"+@chart_element+"-container .legend-container"))
      $("#"+new_id).html(@name_map[k])
      $("#"+new_id).addClass(@color_map[k])

      $("#"+new_id).click (evt) ->
        $("#"+evt.target.id).toggleClass("graph-hidden")
        [..., last] = evt.target.id.split("-")
        op = $("#"+evt.target.id).hasClass("graph-hidden")
        d3.selectAll("svg."+self.chart_element+"-chart-svg ."+last).classed("hidden", op)

window.TrendChart = TrendChart
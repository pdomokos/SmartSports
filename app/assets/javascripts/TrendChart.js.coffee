#= require BaseChart

class TrendChart
  constructor: (@chart_element, @data, @series_keys, series_names, @side_keys, series_colors, @labels, @zero_when_missing=false, @aspect=2.0/7) ->
    console.log "TrendChart"
    @base_r = 3
    @selected_r = 8
    @preproc_cb = null

    @margin = {top: 20, right: 40, bottom: 20, left: 30}

    @width = $("#"+@chart_element+"-container").parent().width()-@margin.left-@margin.right
    @height = @aspect*@width-@margin.top-@margin.bottom

    @n = @series_keys.length
    @color_map = {}
    @name_map = {}
    @side_map = {}
    for i in [0..@n-1]
      @color_map[@series_keys[i]] = series_colors[i]
      @name_map[@series_keys[i]] = series_names[i]
      @side_map[@series_keys[i]] = @side_keys[i]

  # get_series() needs to be provided in subclass

  get_time_extent: () ->
    return d3.extent(@series, (d) -> new Date(d.date))

  get_value_extent: (keys) ->
    ext = null
    for k in keys
      if ext == null
        ext = d3.extent(@series, (d) -> d[k])
      else
        newext = d3.extent(@series, (d) -> d[k])
        ext = [Math.min(ext[0], newext[0]), Math.max(ext[1], newext[1])]
    return ext

  draw: (date) ->
    self = this

    hash = @get_series()
    hashkeys = Object.keys(hash)
    hashkeys.sort()

    @series = hashkeys.map( (k) -> hash[k])
    if @preproc_cb != null
      @preproc_cb(@series)
    console.log "draw - series"

    @add_legend()

    svg = d3.select($("#"+@chart_element+"-container svg."+@chart_element+"-chart-svg")[0])
    svg = svg
      .attr("width", self.width+self.margin.left+self.margin.right)
      .attr("height", self.height+self.margin.top+self.margin.bottom)
      .append("g")
      .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")

    time_extent = @get_time_extent()
    time_scale = d3.time.scale().domain(time_extent).range([0, self.width])

    @line = {}
    @ext_map = {}
    @scale_map = {}

    ext_left = @get_value_extent([0..@n-1].filter( (i) -> self.side_keys[i] == 'left').map( (i) -> self.series_keys[i]))
    scale_left = d3.scale.linear().range([self.height - self.margin.bottom, self.margin.top]).domain(ext_left)
    ext_right = @get_value_extent( [0..@n-1].filter( (i) -> self.side_keys[i] == 'right').map( (i) -> self.series_keys[i]))
    scale_right = d3.scale.linear().range([self.height - self.margin.bottom, self.margin.top]).domain(ext_right)

    if @zero_when_missing
      ext_left[0] = 0
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
      .attr("transform", "translate(0," + (self.height-self.margin.top) + ")")
      .call(time_axis)
    svg.select(".x.axis")
      .append("text")
      .text("Date")
      .attr("x", (self.width / 2) - self.margin.left)
      .attr("y", self.margin.bottom+self.margin.top)

    y_axis_left = d3.svg.axis().scale(scale_left).orient("left")
    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate( 0, 0 )")
      .attr("stroke-width", "0")
      .call(y_axis_left)
    svg.select(".y.axis")
      .append("text")
      .text(self.labels[0])
      .attr("transform", "translate(-20, 0)")

    y_axis_right = d3.svg.axis().scale(scale_right).orient("right")
    svg.append("g")
      .attr("class", "hr axis")
      .attr("transform", "translate( "+@width.toString()+", 0 )")
      .attr("stroke-width", "0")
      .call(y_axis_right)
    svg.select(".hr.axis")
      .append("text")
      .text(self.labels[1])
      .attr("transform", "translate(-20, 0)")

    for k in @series_keys
      svg.selectAll("circle."+k+"-avg")
        .data(self.series.filter( (d) -> d[k]!=null))
        .enter()
        .append("circle")
        .attr("cx", (d) -> time_scale(new Date(d.date)))
        .attr("cy", (d) -> self.scale_map[k](d[k]))
        .attr("r", @base_r)
        .attr("class", self.color_map[k]+" "+k)

      svg.append("path")
        .datum(self.series.filter( (d) -> d[k]!=null))
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
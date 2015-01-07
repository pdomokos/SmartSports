#= require BaseChart

class TrendChart
  constructor: (@connection, @chart_element, @data, @series_keys, series_names, @scale_keys, series_colors, @labels, @zero_when_missing=false) ->

    console.log "TrendChart"
    @base_r = 3
    @selected_r = 8
    @preproc_cb = null

    @margin = {top: 20, right: 40, bottom: 20, left: 30}
    aspect = 200/700
    @width = $("#"+@chart_element+"-container").parent().width()-@margin.left-@margin.right
    @height = aspect*@width-@margin.top-@margin.bottom

    @scale_map = {'left': [], 'right': []}
    @axis_map = {}
    @color_map = {}
    @name_map = {}
    for i in [0..@series_keys.length-1]
      @axis_map[@series_keys[i]] = @scale_keys[i]
      arr = @scale_map[@scale_keys[i]]
      arr.push(@series_keys[i])
      @color_map[@series_keys[i]] = series_colors[i]
      @name_map[@series_keys[i]] = series_names[i]

  preprocess: () ->
    console.log "preprocess"
    console.log "data size = "+@data.length.toString()
    console.log @data[0]

    daily = Object()
    for d in @data
      key = fmt(new Date(Date.parse(d.date)))
      if daily[key]
        daily[key].push(d)
      else
        daily[key] = [d]

    @series = @get_series_avg(daily, @series_keys)
    if @preproc_cb != null
      @preproc_cb(@series)
    console.log @series

  get_series_avg: (data, columns) ->
    result = Object()
    for col in columns
      result[col] = []

    days = Object.keys(data)
    if days == null
      return null
    days.sort()

    for day in days
      for col in columns
        daily_data = data[day]
        avg_value = @get_avg(daily_data, col)
        if(avg_value != null)
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
      if @zero_when_missing
        return 0
      else
        return null
    else
      return sum/len

  get_time_extent: (series, keys) ->
    data = []
    for k in keys
      data = data.concat(series[k])
    return d3.extent(data, (d) -> new Date(d.date))
  get_value_extent: (series, keys) ->
    data = []
    for k in keys
      data = data.concat(series[k])
    return d3.extent(data, (d) -> d.value)

  draw: (date) ->
    self = this

    @preprocess()
    @add_legend()

    svg = d3.select($("#"+@chart_element+"-container svg."+@chart_element+"-chart-svg")[0])
    svg = svg
      .attr("width", self.width+self.margin.left+self.margin.right)
      .attr("height", self.height+self.margin.top+self.margin.bottom)
      .append("g")
      .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")

    time_extent = @get_time_extent(@series, @series_keys)
    time_scale = d3.time.scale().domain(time_extent).range([0, self.width])

    @y_scale = {}
    @line = {}
    for k in ['left', 'right']
      ext = @get_value_extent(@series, @scale_map[k])
      if @zero_when_missing
        ext[0] = 0
      @y_scale[k] = d3.scale.linear().range([self.height - self.margin.bottom, self.margin.top]).domain(ext)

      @line[k] = d3.svg.line()
        .x( (d) -> return(time_scale(new Date(d.date))))
        .y( (d) -> return(self.y_scale[self.axis_map[k]](d.value)))

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

    y_axis = d3.svg.axis().scale(self.y_scale['left']).orient("left")
    svg.append("g")
      .attr("class", "y axis")
      .attr("transform", "translate( 0, 0 )")
      .attr("stroke-width", "0")
      .call(y_axis)
    svg.select(".y.axis")
      .append("text")
      .text(self.labels[0])
      .attr("transform", "translate(-20, 0)")

    hr_axis = d3.svg.axis().scale(self.y_scale['right']).orient("right")
    svg.append("g")
      .attr("class", "hr axis")
      .attr("transform", "translate( "+@width.toString()+", 0 )")
      .attr("stroke-width", "0")
      .call(hr_axis)
    svg.select(".hr.axis")
      .append("text")
      .text(self.labels[1])
      .attr("transform", "translate(-20, 0)")


    for k in @series_keys
      data = self.series[k]
      svg.selectAll("circle."+k+"-avg")
        .data(data)
        .enter()
        .append("circle")
        .attr("cx", (d) -> time_scale(new Date(d.date)))
        .attr("cy", (d) -> self.y_scale[self.axis_map[k]](d.value))
        .attr("r", @base_r)
        .attr("class", self.color_map[k])

      svg.append("path")
        .datum(data)
        .attr("class", "line "+self.color_map[k])
        .attr("d", self.line[self.axis_map[k]]);

  add_legend: () ->
    for k in @series_keys
      new_label = $("#legend-template").children().first().clone()
      new_id =  "legend-label-" + k
      new_label.attr('id', new_id)
      new_label.appendTo($("#legend-container"))
      $("#"+new_id).html(@name_map[k])
      $("#"+new_id).addClass(@color_map[k])

window.TrendChart = TrendChart
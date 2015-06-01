class TimeLine
  constructor: (@chart_element_selector, @data, @date) ->
    console.log "TimeLine created"

    @svg = d3.select(@chart_element_selector).append("svg")
    console.log @svg
    @margin = {top: 20, right: 30, bottom: 20, left: 40}
    @aspect = 1.0/7.0

    console.log @chart_element_selector
    @width = $(@chart_element_selector).width()
    console.log @width
    @height = @aspect*@width
    console.log @height
    total_height = @height
    @svg
      .attr("width", @width)
      .attr("height", total_height)

  draw: () ->
    self = this
    time_extent = [new Date(@date+" 00:00:00").getTime(), new Date(@date+" 23:59:59").getTime()]
    @time_scale = d3.time.scale().domain(time_extent).range([0, self.width-self.margin.left-self.margin.right])

    y_extent = [0, 10]
    @y_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(y_extent)

    time_axis = d3.svg.axis()
      .scale(@time_scale)
      .ticks(10)

    @svg.append("clipPath")
      .attr("id", "chart-clip")
      .append("rect")
      .attr("x", 0)
      .attr("y", 0)
      .attr("width", self.width-self.margin.right )
      .attr("height", self.height-self.margin.top)

    @svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate("+self.margin.left+","+(self.height-self.margin.bottom)+")")
      .call(time_axis)

    canvas = @svg
      .append("g")
      .attr("transform", "translate("+self.margin.left+","+(self.margin.top)+")")
      .attr("clip-path", "url(#chart-clip)")

#    y_axis = d3.svg.axis().scale(y_scale).orient("left")
#    @svg.append("g")
#      .attr("class", "y axis")
#      .attr("transform", "translate("+self.margin.left+","+self.margin.top+")")
#      .attr("stroke-width", "0")
#      .call(y_axis)
#      .append("text")
#      .text(yAxisText)

    #==========

    console.log @data

    linedata = $.grep(@data, (item) ->
      return (item.evt_type=='exercise'||item.evt_type=='lifestyle')
    )
    console.log "linedata"
    console.log linedata
    @draw_linedata(canvas, linedata)

    pointdata = $.grep(@data, (item) ->
      return (item.evt_type!='exercise' && item.evt_type!='lifestyle')
    )

    console.log "pointdata"
    console.log pointdata
    @draw_pointdata(canvas, pointdata)

    $(@chart_element_selector+' g[data-tooltip!=""]').qtip({
      content: {
        attr: 'data-tooltip'
      }
      position: {
        target: 'mouse',
        my: 'bottom center',
        adjust: { y: 70}
      }
    })

  draw_linedata: (canvas, data) ->
    self = this
    groups = canvas.selectAll("g").data(data)
    groupsEnter = groups.enter().append("g")
      .attr("id", (d) -> d.id)
      .attr("data-tooltip", (d) -> d.title)
      .attr("data-titlebar", true)
      .attr("data-title", "Exercise")

    groupsEnter.append("line").attr("class", (d)->d.evt_type+" timeLines")
    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePoints timePointsA")
    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePointsInner timePointsAInner")
    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePoints timePointsB")
    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePointsInner timePointsBInner")

    groupsEnter.select("line")
      .attr("x1", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("y1", (d) -> self.y_scale(d.depth))
      .attr("x2", (d) -> self.time_scale(d.dates[1].getTime()))
      .attr("y2", (d) -> self.y_scale(d.depth))

    groupsEnter.selectAll("circle.timePointsA")
      .attr("cx", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("cy", (d) -> self.y_scale(d.depth))
      .attr("r", "5")

    canvas.selectAll("circle.timePointsAInner")
      .attr("cx", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("cy", (d) -> self.y_scale(d.depth))
      .attr("r", "2")

    groupsEnter.selectAll("circle.timePointsB")
      .attr("cx", (d) -> self.time_scale(d.dates[1].getTime()))
      .attr("cy", (d) -> self.y_scale(d.depth))
      .attr("r", "5")

    canvas.selectAll("circle.timePointsBInner")
      .attr("cx", (d) -> self.time_scale(d.dates[1].getTime()))
      .attr("cy", (d) -> self.y_scale(d.depth))
      .attr("r", "2")

  draw_pointdata: (canvas, data) ->
    self = this
    groups = canvas.selectAll("g").data(data)
    groupsEnter = groups.enter().append("g")
      .attr("id", (d) -> d.id)
      .attr("data-tooltip", (d) -> d.title)
      .attr("data-titlebar", true)

    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePoints timePointsA")
    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePointsInner timePointsAInner")

    groupsEnter.selectAll("circle.timePointsA")
      .attr("cx", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("cy", (d) -> self.y_scale(d.depth))
      .attr("r", "5")

    canvas.selectAll("circle.timePointsAInner")
      .attr("cx", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("cy", (d) -> self.y_scale(d.depth))
      .attr("r", "2")

window.TimeLine = TimeLine

class TimeLine
  constructor: (@chart_element_selector, @data, @day) ->
    console.log "TimeLine created for : "+@day

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
    time_extent = [new Date(moment(self.day+" 00:00:00")).getTime(), new Date(moment(self.day+" 23:59:59")).getTime()]
    @time_scale = d3.time.scale().domain(time_extent).range([0, self.width-self.margin.left-self.margin.right])

    y_extent = [0, 10]
    @y_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(y_extent)

    time_axis = d3.svg.axis()
      .scale(@time_scale)
      .ticks(10)

    hr_extent = [20, 200]
    @hr_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(hr_extent)
    bp_extent = [50, 200]
    @bp_scale = d3.scale.linear().range([self.height - self.margin.bottom- self.margin.top, 0]).domain(bp_extent)

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
    sensordata = $.grep(@data, (item) ->
      return (item.evt_type=='sensor')
    )
    @data = $.grep(@data, (item) ->
      return (item.evt_type!='sensor')
    )

    linedata = $.grep(@data, (item) ->
      return (item.evt_type=='exercise'||item.evt_type=='wellbeing')
    )
    console.log "linedata"
    console.log linedata
    @draw_linedata(canvas, linedata)

    bpdata = $.grep(@data, (item) ->
      return (item.evt_type=='measurement'&&item.meas_type=='blood_pressure')
    )

    pointdata = $.grep(@data, (item) ->
      return (item.evt_type!='exercise' && item.evt_type!='lifestyle' && (item.evt_type!='measurement'||item.meas_type!='blood_pressure'))
    )

    console.log "pointdata"
    console.log pointdata
    @draw_pointdata(canvas, pointdata)

    console.log "bpdata"
    console.log bpdata
    @draw_bpdata(canvas, bpdata)

    for sens in sensordata
      @draw_sensordata(canvas, sens)

    $(@chart_element_selector+' [data-tooltip!=""]').each () ->
      $(this).qtip({
        content: {
          title: $(this).attr('data-title'),
          text: $(this).attr('data-tooltip')
        }
        titlebar: {
          attr: 'data-title'
        }
        position: {
          my: 'bottom center',
          at: 'top center',
          viewport: $('#chart-clip')
        }
        style: {
          classes: 'qtip-default qtip qtip-green qtip-shadow qtip-rounded'
        }
    })

  draw_linedata: (canvas, data) ->
    getTooltip = (d) ->
      title = d.tooltip+
          "<br/>Duration:"+((d.dates[1]-d.dates[0])/60.0/1000.0).toFixed(2)+"min"+
          "<br/>At: "+moment(d.dates[0]).format("YYYY-MM-DD HH:mm:SS")+
      "<br/>Source: "+d.source
      return title
    self = this
    groups = canvas.selectAll("g.linedata").data(data)
    groupsEnter = groups.enter().append("g")
      .attr("id", (d) -> d.id)
      .attr("data-tooltip", getTooltip  )
      .attr("data-titlebar", 'true')
      .attr("data-title", (d) -> d.title)
      .attr("class", "linedata")

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
    getTooltip = (d) ->
      title = d.tooltip+
          "<br/>At: "+moment(d.dates[0]).format("YYYY-MM-DD HH:mm:SS")+
          "<br/>Source: "+d.source
      return title

    groups = canvas.selectAll("g.pointdata").data(data)
    groupsEnter = groups.enter().append("g")
      .attr("id", (d) -> d.id)
      .attr("data-tooltip", getTooltip)
      .attr("data-titlebar", true)
      .attr("data-title", (d) -> d.title)
      .attr("class", "pointdata")

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

  draw_bpdata: (canvas, data) ->
    self = this
    groups = canvas.selectAll("g.healthdata").data(data)

    getTooltip = (d) ->
      title = d.tooltip+
          "<br/>At: "+moment(d.dates[0]).format("YYYY-MM-DD HH:mm:SS")+
          "<br/>Source: "+d.source
      return title

    groupsEnter = groups.enter().append("g")
      .attr("id", (d) -> d.id)
      .attr("data-tooltip", getTooltip)
      .attr("data-titlebar", true)
      .attr("data-title", (d) -> d.title)
      .attr("class", "healthdata")

    groupsEnter.append("line").attr("class", (d)->d.evt_type+" timeLines")
    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePoints timePointsA")
    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePointsInner timePointsAInner")
    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePoints timePointsB")
    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePointsInner timePointsBInner")
    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePoints timePointsC")
    groupsEnter.append("circle").attr("class", (d)->d.evt_type+" timePointsInner timePointsCInner")

    groupsEnter.select("line")
      .attr("x1", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("y1", (d) -> self.bp_scale(d.values[0]))
      .attr("x2", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("y2", (d) -> self.bp_scale(d.values[1]))

    groupsEnter.selectAll("circle.timePointsA")
      .attr("cx", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("cy", (d) -> self.bp_scale(d.values[0]))
      .attr("r", "5")

    groupsEnter.selectAll("circle.timePointsAInner")
      .attr("cx", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("cy", (d) -> self.bp_scale(d.values[0]))
      .attr("r", "2")

    groupsEnter.selectAll("circle.timePointsB")
      .attr("cx", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("cy", (d) -> self.bp_scale(d.values[1]))
      .attr("r", "5")

    groupsEnter.selectAll("circle.timePointsBInner")
      .attr("cx", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("cy", (d) -> self.bp_scale(d.values[1]))
      .attr("r", "2")

    groupsEnter.selectAll("circle.timePointsC")
      .attr("cx", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("cy", (d) -> self.bp_scale(d.values[2]))
      .attr("r", "5")
    groupsEnter.selectAll("circle.timePointsCInner")
      .attr("cx", (d) -> self.time_scale(d.dates[0].getTime()))
      .attr("cy", (d) -> self.bp_scale(d.values[2]))
      .attr("r", "2")

  draw_sensordata: (canvas, data ) ->
    self = this
    console.log data
    rrline = d3.svg.line()
      .x( (d) ->
        t = new Date(0)
        t.setUTCSeconds(d.time)
        return(self.time_scale(t)))
      .y( (d) -> return(self.hr_scale(d.data)))

    canvas.append("path")
      .attr("class", "line rr")
      .attr("d", rrline(data.values))
      .attr("data-tooltip", data.tooltip)
      .attr("data-titlebar", true)
      .attr("data-title", data.title)

window.TimeLine = TimeLine

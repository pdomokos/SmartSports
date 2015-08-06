@analytics2_loaded = () ->
  self = this
  uid = $("#current-user-id")[0].value

  if $("#selected-user-id").length >0
    suid = $("#selected-user-id")[0].value
    if suid && suid != ''
      uid = suid

  $("div.appMenu button").removeClass("selected")
  $("#analytics-link").css
    background: "rgba(240, 108, 66, 0.3)"

  $(document).on("click", "#add-analysis", (evt) ->
    console.log("add analysis clicked")
    if !self.bg_trend_chart
      return

    data = self.bg_trend_chart.data

    self.bg_trend_chart.add_highlight("2015-07-12", "2015-07-19", "selA")
    self.bg_trend_chart.add_highlight("2015-07-19", "2015-07-26", "selB")

    labels = true

    minv = Infinity
    maxv = -Infinity
    boxData = {}
    data.forEach( (d)->
      if d.blood_sugar > maxv
        maxv = d.blood_sugar
      if d.blood_sugar < minv
        minv = d.blood_sugar
      t = d.blood_sugar_time
      if(!boxData[t])
        boxData[t] = [d.blood_sugar]
      else
        boxData[t].push(d.blood_sugar)
    )
    boxDataArr = []
    Object.keys(boxData).forEach( (d) ->
      tmp = [d]
      tmp.push(boxData[d])
      boxDataArr.push(tmp)
    )
    window.boxDataArr = boxDataArr
    margin = {top: 40, right: 40, bottom: 40, left: 40}

    width = $("#stat-1-container").parent().width()/2
    height = width*2.0/7.0

    chart = d3.box()
      .whiskers(iqr(1.5))
      .width(width-margin.left-margin.right)
      .height(height-margin.top-margin.bottom)
      .domain([minv, maxv])
      .showLabels(labels)
      .tickFormat(d3.format(",.02f"))
    console.log svg
    console.log boxDataArr
    console.log "width=["+toString(width)+"]"
    console.log height
    bpWidth = 20
    bpHeight = 420
    #(width-margin.left-margin.right)/boxDataArr.length

    svg = d3.select("#stat-1-container > div")
    .append("svg")
        .attr("class", "box")
        .attr("width", width )
        .attr("height", height )
        .append("g")
          .attr("transform", "translate(" + 0 + "," + 0 + ")")

    x = d3.scale.ordinal()
        .domain( boxDataArr.map( (d) -> console.log(d); return d[0]  ) )
        .rangeRoundBands([0 , width], 0.7, 0.3)

    xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom");

    y = d3.scale.linear()
      .domain([minv, maxv])
      .range([height + margin.top, 0 + margin.top])

    yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")

    svg.selectAll(".box")
      .data(boxDataArr)
      .enter()
        .append("g")
        .attr("transform", (d) -> return "translate(" +  x(d[0])  + "," + margin.top + ")"  )
        .call(chart.width(x.rangeBand()))
  )

  d3.json("/users/"+uid+"/measurements.json?meas_type=blood_sugar", bg_data_received)


bg_data_received = (jsondata) ->
  @bg_trend_chart = new BGChart("bg", jsondata, 1.0/8)
  @bg_trend_chart.draw()



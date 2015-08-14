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

  d3.json("/users/"+uid+"/measurements.json?meas_type=blood_sugar", bg_data_received)

  $(document).on("click", "#add-analysis", (evt) ->
    console.log("add analysis clicked")
    if !self.bg_trend_chart
      return

    data = self.bg_trend_chart.data

    rangeA = ["2015-07-12", "2015-07-19"]
    rangeB = ["2015-07-19", "2015-07-26"]
    self.bg_trend_chart.add_highlight(rangeA[0], rangeA[1], "selA")
    self.bg_trend_chart.add_highlight(rangeB[0], rangeB[1], "selB")

    labels = true

    lbMap = {
    '48': 'Unspecified',
    '57': 'Unspecified2',
    '58': 'Pre Breakfast',
    '59': 'Post Breakfast',
    '60': 'Pre Lunch',
    '61': 'Post Lunch',
    '62': 'Pre Supper',
    '63': 'Post Supper',
    '64': 'Pre Snack'
    }
    minv = Infinity
    maxv = -Infinity
    boxDataA = {}
    boxDataB = {}
    console.log data[0]
    data.forEach( (d)->
      if d.blood_sugar > maxv
        maxv = d.blood_sugar
      if d.blood_sugar < minv
        minv = d.blood_sugar
      t = d.blood_sugar_time
      selData = null

      dd = new Date(d.date)
      if(dd>= new Date(rangeA[0]) && dd < new Date(rangeA[1]))
        selData = boxDataA
      if(dd>= new Date(rangeB[0]) && dd < new Date(rangeB[1]))
        selData = boxDataB
      if( selData )
        if(!selData[t])
          selData[t] = [d.blood_sugar]
        else
          selData[t].push(d.blood_sugar)
    )
    boxDataArrA = []
    boxDataArrB = []
    Object.keys(boxDataA).forEach( (d) ->
      tmp = [d]
      tmp.push(boxDataA[d])
      boxDataArrA.push(tmp)
    )
    Object.keys(boxDataB).forEach( (d) ->
      tmp = [d]
      tmp.push(boxDataB[d])
      boxDataArrB.push(tmp)
    )
    window.boxDataArrA = boxDataArrA
    window.boxDataArrB = boxDataArrB
    margin = {top: 30, right: 40, bottom: 55, left: 40}

    width = $("#stat-1-container").parent().width()/2
    height = width*2.0/7.0

    chart = d3.box()
      .whiskers(iqr(1.5))
      .width(width-margin.left-margin.right)
      .height(height-margin.top-margin.bottom)
      .domain([minv, maxv])
      .showLabels(labels)
      .tickFormat(d3.format(",.02f"))

    bpWidth = 20
    bpHeight = 420
    #(width-margin.left-margin.right)/boxDataArr.length

    svg = d3.select("#stat-1-container > div")
      .append("svg")
        .attr("class", "box")
        .attr("width", width )
        .attr("height", height )
    dwg = svg
      .append("g")
        .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    x = d3.scale.ordinal()
        .domain(  boxDataArrA.concat(boxDataArrB).map( (d) -> console.log(d); console.log(lbMap[d[0]]); return lbMap[d[0]]  )  )
        .rangeRoundBands([0 , width], 0.7, 0.3)

    xAxis = d3.svg.axis()
      .scale(x)
      .orient("bottom");

    y = d3.scale.linear()
      .domain([minv, maxv])
      .range([height-margin.top-margin.bottom, 0])

    yAxis = d3.svg.axis()
      .scale(y)
      .orient("left")

    barwidth = x.rangeBand()/3.0
    console.log "barwidht = "+toString(barwidth)
    window.barwidht = barwidth
    dwg.selectAll("g.boxA")
      .data(boxDataArrA)
      .enter()
        .append("g")
        .attr("class","boxA")
        .attr("transform", (d) -> return "translate(" +  x(lbMap[d[0]])  + "," + 0 + ")"  )
        .call(chart.width(barwidth))

    dwg.selectAll("g.boxB")
      .data(boxDataArrB)
      .enter()
        .append("g")
        .attr("class","boxB")
        .attr("transform", (d) -> return "translate(" +  x(lbMap[d[0]])+barwidth*2  + "," + 0 + ")"  )
        .call(chart.width(barwidth))

    # draw y axis
    dwg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
      .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .style("font-size", "16px")
        .text("BG (mmol/L)");

    # draw x axis
    dwg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + ( height-margin.bottom) + ")")
      .call(xAxis)
      .append("text")
        .attr("x", (width / 3) )
        .attr("y",  -20 )
        .attr("dy", ".71em")
        .style("text-anchor", "middle")
        .style("font-size", "16px")
        .text("Measurement");
  )

bg_data_received = (jsondata) ->
  @bg_trend_chart = new BGChart("bg", jsondata, 1.0/8)
  @bg_trend_chart.draw()



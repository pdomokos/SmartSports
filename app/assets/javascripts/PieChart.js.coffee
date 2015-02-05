
class PieChart
  constructor: (@chart_element, @data, @aspect=3.0/7) ->
    console.log "PieChart"

    @margin = {top: 40, right: 40, bottom: 40, left: 40}

    @width = $("#"+@chart_element+"-container").parent().width()
    @height = @aspect*@width

  draw: () ->
    self = this
    console.log "draw pie chart"

    elem = $("#"+@chart_element+"-container svg.pie-chart")
    elem.empty()
    svg = d3.select(elem[0])
    svg = svg
      .attr("width", @width)
      .attr("height", @height)
      .append("g")
        .attr("transform", "translate(110, 110)")

    radius = 90

    fullarc = d3.svg.arc()
      .innerRadius(0)
      .outerRadius(radius)
      .startAngle(0)
      .endAngle(2*Math.PI)

    value = 0
    arc_data = []
    index = 0
    for d in @data
      value = value+d[1]
      arc_data.push({"label": d[0], "value": value, "index": index})
      index += 1

    arc = d3.svg.arc()
      .outerRadius(radius)
      .innerRadius(0)

    pie = d3.layout.pie()
      .sort(null)
      .value( (d) ->  d.value )

    col = ["colset6_0", "colset6_1", "colset6_2", "colset6_3", "colset6_4"]
    g = svg.selectAll(".arc")
      .data(pie(arc_data))
      .enter()
      .append("g")
      .attr("class", "arc")

    g.append("path")
      .attr("d", arc)
      .attr("class", (d) ->
        return (col[d.data.index])
      )

window.PieChart = PieChart


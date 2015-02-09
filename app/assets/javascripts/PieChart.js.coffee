
class PieChart
  constructor: (@chart_element, @data, @data_weekly=null, @aspect=3.0/7) ->
    console.log "PieChart"

    @margin = {top: 40, right: 40, bottom: 40, left: 40}

    @width = $("#"+@chart_element+"-container").parent().width()
    @height = @aspect*@width
#    @col = ["colset6_0", "colset6_1", "colset6_2", "colset6_3", "colset6_4"]

  draw: () ->
    self = this
    console.log "draw pie chart"

    elem = $("#"+@chart_element+"-container svg.pie-chart")
    elem.empty()
    svg = d3.select(elem[0])
    @radius = 90

    svg1 = svg
      .attr("width", @width)
      .attr("height", @height)
      .append("g")
        .attr("transform", "translate(120, 110)")

    svg2 = svg
      .append("g")
      .attr("transform", "translate(370, 110)")

    @draw_pie(svg1, @data)
    @draw_pie(svg2, @data_weekly )
    @add_legend(@data)

  draw_pie: (elem, chart_data) ->
    self = this
    arc_data = []
    index = 0

    total = chart_data.map( (d) -> d[1] ).reduce( (a, b) -> a+b)

    for d in chart_data
      arc_data.push({"label": d[0], "value": d[1], "index": index})
      index += 1

    arc = d3.svg.arc()
      .outerRadius(self.radius)
      .innerRadius(0)

    pie = d3.layout.pie()
      .sort(null)
      .value( (d) ->  d.value )

    g = elem.selectAll(".arc")
      .data(pie(arc_data))
      .enter()
      .append("g")
      .attr("class", "arc")

    g.append("path")
      .attr("d", arc)
      .attr("class", (d) ->
        return (d.data.label)
      )
      .on("mouseover", (d) ->
        data = d['data']
        v = data['value']
        $("#daily-piechart-container div.notes").html(capitalize(data['label'])+": "+(data['value']/total*100).toFixed(2)+"%")
        currelement = d3.select(this)
        currelement.classed("selected", true)
      )
      .on("mouseout", (d) ->
        $("#daily-piechart-container div.notes").html("")
        currelement = d3.select(this)
        currelement.classed("selected", false)
      )

    g.append("text")
      .each( (dat) ->
        curr = d3.select(this)
        if dat.data.value/total*100 > 10
          curr.attr("transform", (d) ->  "translate(" + arc.centroid(d) + ")" )
            .attr("dy", ".35em")
            .style("text-anchor", "middle")
            .text( (d) -> (d.data.value/total*100).toFixed(2) )
    )

  add_legend: (data) ->
    self = this
    i = 0
    for k in data
      new_label = $("#legend-template").children().first().clone()
      tmp = @chart_element.replace("-", "_")
      new_id =  "legend-label_"+tmp+"-" + k[0]
      new_label.attr('id', new_id)
      new_label.appendTo($("#"+@chart_element+"-container .legend-container"))
      $("#"+new_id).html(capitalize(k[0]))
      $("#"+new_id).addClass(k[0])
      $("#"+new_id).on("mouseover", (d) ->
        act = this.id.split("-")[-1..][0]
        d3.selectAll("#daily-piechart-container path."+act).classed("selected", true))
      $("#"+new_id).on("mouseout", (d) ->
        act = this.id.split("-")[-1..][0]
        d3.selectAll("#daily-piechart-container path."+act).classed("selected", false))
      i += 1

window.PieChart = PieChart

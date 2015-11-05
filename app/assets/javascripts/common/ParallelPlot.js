function ParallelPlot(chartElement, data, yLabel) {
    this.chartElement = chartElement;
    this.chartData = data;
    this.yLabel = yLabel;
    this.colorMap = getColorMap(data);
    this.margin = {top: 30, right: 40, bottom: 55, left: 40};
    this.baseR = 4;
}

ParallelPlot.prototype.draw = function(rangeA, rangeB) {
    self = this;
    colorMap = getColorMap(this.chartData);
    parDataA = {};
    parDataB = {};
    dotData = [];

    a0 = new Date(rangeA[0]);
    a1 = new Date(rangeA[1]);
    a1.setHours(23);
    a1.setMinutes(59);
    a1.setSeconds(59);
    b0 = new Date(rangeB[0]);
    b1 = new Date(rangeB[1]);
    b1.setHours(23);
    b1.setMinutes(59);
    b1.setSeconds(59);
    console.log("ranges:");
    console.log(rangeA);
    console.log(rangeB);

    this.chartData.forEach( function(d) {
        selData = null;
        dd = moment(d.date).toDate();

        if((dd >= a0) && (dd < a1)) {
            selData = parDataA;
        }
        if ((dd >= b0) && (dd < b1)) {
            selData = parDataB;
        }

        if (selData) {
            dd = moment(d.date).toDate();
            t = fmt(dd);
            dd.setYear(2015);
            dd.setMonth(0);
            dd.setDate(0);
            item = {date: fmt_hms(dd), value: d.value, group: d.group};
            if (!selData[t])
                selData[t] = [item];
            else
                selData[t].push(item);
            dotData.push(item);
        } else {
            console.log("missing:");
            console.log(dd);
        }
    });

    width = $("#"+this.chartElement).parent().width()/2;
    height = width*2.0/7.0;

    svg = d3.select("#"+this.chartElement+" > div")
        .append("svg")
        .attr("class", "box")
        .attr("width", width )
        .attr("height", height );
    dwg = svg
        .append("g")
        .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");

    var arr = [];
    function addKeys(arr, dict) {
        Object.keys(dict).forEach( function(k) {
            dict[k].forEach(function(v) {
                arr.push(v.date);
            })
        })
    }
    addKeys(arr, parDataA);
    addKeys(arr, parDataB);
    console.log(arr);
    time_extent = d3.extent(arr, function(d) {return moment(d).toDate()} );
    console.log(time_extent);
    d1 = time_extent[0];
    d2 = time_extent[1];
    d1.setHours(0);
    d1.setMinutes(0);
    d2.setHours(23);
    d2.setMinutes(59);
    time_extent[0] = d1;
    time_extent[1] = d2;

    time_scale = d3.time.scale().domain(time_extent).range([0, width-this.margin.left-this.margin.right]);

    bg_extent = d3.extent(this.chartData, function(d) { return  d.value});
    scale_left = d3.scale.linear().range([height - this.margin.bottom- this.margin.top, 0]).domain(bg_extent);

    bgline = d3.svg.line()
        .x( function(d) { return(time_scale(moment(d.date).toDate()))})
        .y( function(d) { return(scale_left(d.value))})

    Object.keys(parDataA).forEach( function(k) {
        dwg.append("path")
            .datum(parDataA[k])
            .attr("class", "pplineA")
            .attr("d", bgline)
    });

    Object.keys(parDataB).forEach(function(k) {
        dwg.append("path")
            .datum(parDataB[k])
            .attr("class", "pplineB")
            .attr("d", bgline);
    });

    dwg.selectAll("circle.bg")
        .data(dotData)
        .enter()
        .append("circle")
        .attr("cx", function(d) {return time_scale(moment(d.date).toDate())})
        .attr("cy", function(d) { return scale_left(d.value)})
        .attr("r", this.baseR)
        .attr("class", function(d) { return colorMap[d.group]});

    xAxis = d3.svg.axis()
        .scale(time_scale)
        .orient("bottom")
        .tickFormat(d3.time.format("%H:%m"));

    yAxis = d3.svg.axis()
        .scale(scale_left)
        .orient("left");

    // draw y axis
    dwg.append("g")
        .attr("class", "y axis")
        .call(yAxis)
        .append("text")
        .attr("transform", "rotate(-90)")
        .attr("y", 6)
        .attr("dy", ".71em")
        .style("text-anchor", "end")
        .style("font-size", "16px")
        .text(this.yLabel);

    // draw x axis
    dwg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + ( height-this.margin.bottom) + ")")
        .call(xAxis)
        .append("text")
        .attr("x", (width / 2) )
        .attr("y",  -20 )
        .attr("dy", ".71em")
        .style("text-anchor", "middle")
        .style("font-size", "16px")
        .text("Time of Day");
}
function LineChart(chartElement, data, title) {
    this.chartElement = chartElement;
    this.chartData = data;
    this.yTitle = title;
    this.margin = {top: 40, right: 40, bottom: 40, left: 40 };
    this.width = $("#"+chartElement+"-container").parent().width();
    this.aspect = 2.0/7;
    this.height = this.aspect*this.width-this.margin.top-this.margin.bottom;
    this.highlights = []
    this.colorMap = getColorMap(data);
}

LineChart.prototype.baseR = 4;
LineChart.prototype.selected_R = 8;
LineChart.prototype.preprocCB = null;

LineChart.prototype.tickUnit = d3.time.week;
LineChart.prototype.ticks = 1;

LineChart.prototype.draw = function() {
    var self = this;
    if( this.preproc_cb != null ) {
        this.preproc_cb(this.chartData);
    }

    this.svg = d3.select($("#"+this.chartElement+"-container svg."+this.chartElement+"-chart-svg")[0]);
    this.svg
        .attr("width", self.width)
        .attr("height", self.height);

    //this.add_legend()
    dlen = this.chartData.length;
    if( this.chartData == null || dlen == 0 ) {
        this.svg.append("text")
            .text("No data")
            .attr("class", "warn")
            .attr("x", this.width / 2 - this.margin.left)
            .attr("y", this.height / 2)
        return;
    }

    var timeExtent = this.calcTimeExtent(this.getTimeExtent());
    this.timeScale = this.getTimeScale(timeExtent);

    this.valueExtent = this.getValueExtent();
    this.scaleLeft = this.getScaleLeft();

    this.line = d3.svg.line()
        .x( function(d)  { return(self.timeScale(moment(d.date).toDate()))})
        .y( function(d) { return(self.scaleLeft(d.value))});

    this.timeAxis = d3.svg.axis()
        .scale(this.timeScale)
        .ticks(this.tickUnit, this.ticks);

    this.svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate("+this.margin.left+","+(this.height-this.margin.bottom)+")")
        .call(this.timeAxis);

    this.yAxis = d3.svg.axis().scale(this.scaleLeft).orient("left");

    this.svg.append("g")
        .attr("class", "y axis")
        .attr("transform", "translate( "+this.margin.left+", "+this.margin.top+" )")
        .attr("stroke-width", "0")
        .call(this.yAxis)
        .append("text")
        .text(this.yTitle)
        .attr("transform", "translate("+(-this.margin.left/2)+", "+(-this.margin.top/2)+")");

    this.svg.append("defs").append("svg:clipPath")
        .attr("id", "clip")
        .append("svg:rect")
            .attr("id", "clip-rect")
            .attr("x", "0")
            .attr("y", "0")
            .attr("width", this.width-this.margin.left-this.margin.right)
            .attr("height", this.height-this.margin.top-this.margin.bottom);

    var canvas = this.svg
        .append("g")
        .attr("clip-path", "url(#clip)")
        .attr("transform", "translate("+this.margin.left+","+this.margin.top+")");

    if(this.chartData.length > 0) {
        canvas.append("path")
            .datum(self.chartData)
            .attr("class", "grayline")
            .attr("d", self.line);

        canvas.selectAll("circle")
            .data(this.chartData)
            .enter()
            .append("circle")
            .attr("cx", function(d) { return self.timeScale(moment(d.date).toDate())} )
            .attr("cy", function(d) { return self.scaleLeft(d.value)})
            .attr("r", this.baseR)
            .attr("class", function(d) { return self.colorMap[d.group]})
            .on("mouseover", function (d) {
                if (this.cb_over)
                    this.cb_over(d, this);
            })
            .on("mouseout", function(d) {
                if( self.cb_out)
                    self.cb_out(d, this);
            })
            .on("click", function(d) {
                if( self.cb_click)
                    self.cb_click(d, this);
            });
    }
}
LineChart.prototype.startZoom = function() {
    this.zoom = d3.behavior.zoom()
        .on('zoom', this.doZoom());
    this.zoom.x(this.timeScale);
    this.svg
        .call(this.zoom)
        .call(this.zoom.event)
}
LineChart.prototype.endZoom = function() {
    this.svg.on(".zoom", null);
}
LineChart.prototype.clearHighlights = function() {
    $("#" +this.chartElement + "-container svg rect.selA").remove()
    $("#" +this.chartElement + "-container svg rect.selB").remove()
    this.highlights = []
}

LineChart.prototype.addHighlight = function(from, to, style) {
    var canvas = d3.select($("#" +this.chartElement + "-container svg." +this.chartElement + "-chart-svg g:last-child")[0]);
    this.highlights.push({from: from, to: to, style: style})
    var w = this.timeScale(moment(to).toDate()) - this.timeScale(moment(from).toDate());
    var extent = this.getValueExtent();
    maxval = Math.max(extent[0], extent[1]);
    canvas.insert("svg:rect", ":first-child")
        .attr("class", style)
        .attr("x", (this.timeScale(moment(from).toDate())))
        .attr("width", w)
        .attr("y", this.scaleLeft(maxval) - this.margin.top)
        .attr("height", this.height - this.margin.bottom);
}

LineChart.prototype.getTimeScale = function (extent) {
    return d3.time.scale().domain(extent).range([0, this.width-this.margin.left-this.margin.right]);
}

LineChart.prototype.getScaleLeft = function() {
    return d3.scale.linear().range([this.height - this.margin.bottom- this.margin.top, 0]).domain(this.valueExtent);
}

LineChart.prototype.getTimeExtent = function () {
    return d3.extent(this.chartData, function(d) { return moment(d.date).toDate() });
}

LineChart.prototype.calcTimeExtent = function (extent) {
    var ret = extent;
    var m0 = moment(extent[0]);
    var m1 = moment(extent[1]);
    if( m1.diff(m0, 'days') > 60) {
        ret = [m1.subtract(60, 'days').toDate(), extent[1]];
    }
    console.log("calcTimeExtent: ")
    console.log(ret)
    return ret;
}

LineChart.prototype.getValueExtent = function () {
    return d3.extent(this.chartData, function(d) { return d.value});
}

LineChart.prototype.addLegend = function () {
    var self = this;
    Object.keys(this.colorMap).forEach( function(k) {
        var new_label = $("#legend-template").children().first().clone();
        var new_id = "legend-labelSEP" +self.chartElement + "SEP" + k;
        new_label.attr('id', new_id);
        new_label.appendTo($("#" +self.chartElement + "-container .legend-container"));
        $("#" + new_id).html(self.nameMap[k]);
        $("#" + new_id).addClass(self.colorMap[k]);
    });
}

LineChart.prototype.doZoom = function() {
    console.log("doZoom called");
    var self = this;
    return function() {
        //console.log(self.chartData);
        var visibleData = self.chartData.filter( function(d) {
            var dt = self.timeScale(moment(d.date).toDate());
            return (dt >= 0 && dt < self.width && d.value > 0);
        });
        if(self.highlights.length>0) {
            self.highlights.forEach(function(h) {
                self.svg.selectAll("rect."+ h.style)
                    .attr("x", function(d) { return self.timeScale(moment(h.from).toDate())})
                    .attr("width", function(d) { return self.timeScale(moment(h.to).toDate()) - self.timeScale(moment(h.from).toDate()) });
            })
        }
        if(visibleData.length>0) {
            self.valueExtent = d3.extent(visibleData, function (d) {
                return d.value
            });
            self.scaleLeft.domain(self.valueExtent).nice();

            self.svg.selectAll("circle")
                .attr("cx", function (d) {
                    return self.timeScale(moment(d.date).toDate())
                })
                .attr("cy", function (d) {
                    return self.scaleLeft(d.value)
                });

            self.svg.selectAll("path.grayline").attr("d", self.line);
            self.svg.select("g.x.axis").call(self.timeAxis);
            self.svg.select("g.y.axis").call(self.yAxis);
        }
    }
}

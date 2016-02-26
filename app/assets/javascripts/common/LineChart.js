"use strict";
function LineChart(chartElement, data, title, chartParams) {
    this.chartElement = chartElement;
    this.chartData = data;
    this.yTitle = title;
    this.margin = {top: 40, right: 60, bottom: 40, left: 60};
    this.width = $("#" + chartElement).parent().width();
    this.aspect = 2.0 / 7;
    this.height = this.aspect * this.width - this.margin.top - this.margin.bottom;
    this.highlights = [];

    function getMap(data, colors) {
        var labelSet = new Set();
        var groups = Object.keys(data);
        groups.forEach(function(g) {
            data[g].forEach(function(item) {
                labelSet.add(item.group);
            })
        });
        var labels = Array.from(labelSet).sort();
        if(colors===undefined) {
            colors = ['col1', 'col2', 'col3', 'col4'];
        }
        var i = 0;
        var colorMap = {};
        labels.forEach(function(elem) {
            if(i>colors.length-1)
                colorMap[elem] = colors[colors.length-1];
            else
                colorMap[elem] = colors[i++];
        });
        return colorMap;
    }
    this.colorMap = getMap(data, chartParams&&chartParams.colors);
    this.getElementClass = function(grp, elementName) {
        return this.colorMap[grp] + elementName
    };
    console.log("colormap", this.colorMap);

    this.baseR = 4;
    this.selected_R = 8;
    this.preprocCB = null;

    this.tickUnit = d3.time.week;
    this.ticks = 1;

    this.draw = function () {
        var self = this;
        if (this.preproc_cb != null) {
            this.preproc_cb(this.chartData);
        }

        this.svg = d3.select($("#" + this.chartElement + " svg")[0]);
        this.svg
            .attr("width", self.width)
            .attr("height", self.height);

        var dlen = this.chartData.length;
        if (this.chartData == null || dlen == 0) {
            this.svg.append("text")
                .text("No data")
                .attr("class", "warn")
                .attr("x", this.width / 2 - this.margin.left)
                .attr("y", this.height / 2);
            return;
        }

        this.timeExtent = this.calcTimeExtent();
        this.timeScale = this.timeExtent && this.calcTimeScale(this.timeExtent);

        function remove(arr, elems) {
            if(elems!=undefined) {
                elems.forEach(function (elem) {
                    var idx = arr.indexOf(elem);
                    if (idx > -1) {
                        arr.splice(idx, 1);
                    }
                })
            }
        }

        this.leftGroups = chartParams&&chartParams.leftGroups;
        this.rightGroups = Object.keys(this.chartData);
        remove(this.rightGroups, this.leftGroups);
        console.log(this.leftGroups, this.rightGroups);

        this.rightExtent = this.calcExtent(this.rightGroups);
        this.rightScale = this.rightExtent && this.calcValueScale(this.rightExtent);


        if(this.leftGroups && this.leftGroups.length>0) {
            this.leftExtent = this.calcExtent(this.leftGroups);
            this.leftScale = this.leftExtent && this.calcValueScale(this.leftExtent);
         }

        console.log(this.leftExtent, this.rightExtent);
        this.timeAxis = d3.svg.axis()
            .scale(this.timeScale)
            .ticks(this.tickUnit, this.ticks);
        this.svg.append("g")
            .attr("class", "x axis")
            .attr("transform", "translate(" + this.margin.left + "," + (this.height - this.margin.bottom) + ")")
            .call(this.timeAxis);

        if(this.rightScale!==undefined) {
            var rightAxis = d3.svg.axis().scale(this.rightScale).orient("right");
            this.svg.append("g")
                .attr("class", "y axis")
                .attr("transform", "translate( " + (this.width - this.margin.left) + ", " + this.margin.top + " )")
                .attr("stroke-width", "0")
                .call(rightAxis)
                .append("text")
                .text("steps")
                .attr("transform", "translate(" + (-this.margin.left / 2) + ", " + (-this.margin.top / 2) + ")");
        }

        if(this.leftScale!==undefined) {
            var leftAxis = d3.svg.axis().scale(this.leftScale).orient("left");
            this.svg.append("g")
                .attr("class", "y axis")
                .attr("transform", "translate( " + (this.margin.left) + ", " + this.margin.top + " )")
                .attr("stroke-width", "0")
                .call(leftAxis)
                .append("text")
                .text("distance(m)")
                .attr("transform", "translate(" + (-this.margin.left / 2) + ", " + (-this.margin.top / 2) + ")");
        }
        this.addLegend();

        this.svg.append("defs").append("svg:clipPath")
            .attr("id", "clip")
            .append("svg:rect")
            .attr("id", "clip-rect")
            .attr("x", "0")
            .attr("y", "0")
            .attr("width", this.width - this.margin.left - this.margin.right)
            .attr("height", this.height - this.margin.top - this.margin.bottom);

        var canvas = this.svg
            .append("g")
            .attr("clip-path", "url(#clip)")
            .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");


        var groups = Object.keys(this.chartData);
        self = this;
        console.log(groups);
        groups.forEach(function(grp) {
            var grpData = self.chartData[grp];
            console.log("doing: ",grp);
            //var extent = self.getExtent(grp);
            var currScale = self.getScale(grp);
            console.log("scale: ",currScale, self.leftGroups, self.rightGroups);
            var inGroups = new Set($.map(grpData, function(d) {return d.group}));
            console.log("INGROUPS: ", inGroups);
            var line = d3.svg.line()
                .x(function (d) {
                    return (self.timeScale(moment(d.date).toDate()))
                })
                .y(function (d) {
                    return (currScale(d.value))
                });

            var lineColor = "grayLine";
            if(inGroups.size===1) {
                lineColor = self.getElementClass(grp, "Line");
            }
            console.log("ingroups.size",inGroups.size,"GRP:", grp, "LINECOLOR: ", lineColor);
            canvas.append("path")
                .datum(grpData)
                //.attr("class", self.colorMap[grp].slice(0,3)+"Line"+" "+grp+"Data")
                .attr("class", lineColor+" "+grp+"Data")
                .attr("d", line);

            canvas.selectAll("circle."+grp+"Data")
                .data(grpData)
                .enter()
                .append("circle")
                .attr("cx", function (d) {
                    return self.timeScale(moment(d.date).toDate())
                })
                .attr("cy", function (d) {
                    return currScale(d.value)
                })
                .attr("r", self.baseR)
                .attr("class", function (d) {
                    return self.getElementClass([d.group], "Point")+" "+d.group.replace(" ", "")+"Data"
                })
                .on("mouseover", function (d) {
                    if (self.cb_over)
                        self.cb_over(d, this);
                })
                .on("mouseout", function (d) {
                    if (self.cb_out)
                        self.cb_out(d, this);
                })
                .on("click", function (d) {
                    if (self.cb_click)
                        self.cb_click(d, this);
                });
        });
    };

    this.clearHighlights = function () {
        $("#" + this.chartElement + "-container svg rect.selA").remove();
        $("#" + this.chartElement + "-container svg rect.selB").remove();
        this.highlights = []
    };

    this.addHighlight = function (from, to, style) {
        var canvas = d3.select($("#" + this.chartElement + "-container svg." + this.chartElement + "-chart-svg g:last-child")[0]);
        this.highlights.push({from: from, to: to, style: style});
        var w = this.timeScale(moment(to).toDate()) - this.timeScale(moment(from).toDate());
        var extent = this.rightExtent;
        var maxval = Math.max(extent[0], extent[1]);
        canvas.insert("svg:rect", ":first-child")
            .attr("class", style)
            .attr("x", (this.timeScale(moment(from).toDate())))
            .attr("width", w)
            .attr("y", this.rightScale(maxval) - this.margin.top)
            .attr("height", this.height - this.margin.bottom);
    };

    this.calcTimeScale = function (extent) {
        return d3.time.scale().domain(extent).range([0, this.width - this.margin.left - this.margin.right]);
    };

    this.calcTimeExtent = function () {
        var result = [Infinity, -Infinity];
        var keys = Object.keys(this.chartData);
        var self = this;
        keys.forEach( function(k) {
            var series = self.chartData[k];
            var ex = d3.extent(series, function (d) {
                return moment(d.date).toDate()
            });
            if(ex[0]<result[0]) {
                result[0] = ex[0];
            }
            if(ex[1]>result[1]) {
                result[1] = ex[1];
            }
        });
        return result;
    };

    this.calcValueScale = function (ex) {
        console.log("calc value scale: ", ex);
        if(ex===undefined) {
            ex = this.valueExtent;
        }
        return d3.scale.linear().range([this.height - this.margin.bottom - this.margin.top, 0]).domain(ex);
    };

    this.calcExtent = function (groups) {
        var result = [Infinity, -Infinity];
        var keys = Object.keys(this.chartData);
        console.log("CALCEXTENT: ", groups);
        var self = this;
        keys.forEach( function(k) {
            console.log("key=", k);
            if(groups.indexOf(k)>-1) {
                    var series = self.chartData[k];
                    console.log("series = ", series);
                    var ex = d3.extent(series, function (d) {
                        return d.value;
                    });
                    console.log("ex=", ex);
                    if (ex[0] < result[0]) {
                        result[0] = ex[0];
                    }
                    if (ex[1] > result[1]) {
                        result[1] = ex[1];
                    }
            }
        });

        if(result[1]>1000)
        {
            result[0] -= 300;
            result[1] += 300;
            if(result[0]===Infinity) {
                result = undefined;
            }
        }
        return result;
    };

    this.getScale = function(grp) {
        console.log("getscale", grp, this.leftGroups, this.rightGroups);
        if(this.leftGroups !== undefined && this.leftGroups.indexOf(grp)>-1) {
            return this.leftScale;
        }
        return this.rightScale;
    };

    this.addLegend = function () {
        var self = this;
        Object.keys(this.colorMap).forEach(function (k) {
            var new_label = $("#legend-template").children().first().clone();
            var new_id = "legend-labelSEP" + self.chartElement + "SEP" + k.replace(" ", "");
            new_label.attr('id', new_id);
            new_label.appendTo($("#" + self.chartElement + " .legend-container"));
            var tag = $("#" + new_id).html(capitalize(k));
            tag.addClass(self.getElementClass(k, "Text"));
            tag.on("click", function() {
                // jQuery addClass doesn't work on svg, so use DOM:
                var d = document.getElementById(self.chartElement);
                var nl = d.querySelectorAll("."+k.replace(" ", "")+"Data");
                for (var i = 0; i < nl.length; ++i) {
                    nl[i].classList.toggle("hidden")
                }
            });
        });
    };
}

function ZoomableLineChart(chartElement, data, title) {
    LineChart.call(this, chartElement, data, title);
    this.doZoom = function () {
        console.log("doZoom called");
        var self = this;
        return function () {
            //console.log(self.chartData);
            var visibleData = self.chartData.filter(function (d) {
                var dt = self.timeScale(moment(d.date).toDate());
                return (dt >= 0 && dt < self.width && d.value > 0);
            });
            if (self.highlights.length > 0) {
                self.highlights.forEach(function (h) {
                    self.svg.selectAll("rect." + h.style)
                        .attr("x", function (d) {
                            return self.timeScale(moment(h.from).toDate())
                        })
                        .attr("width", function (d) {
                            return self.timeScale(moment(h.to).toDate()) - self.timeScale(moment(h.from).toDate())
                        });
                })
            }
            if (visibleData.length > 0) {
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
    };
    this.startZoom = function () {
        this.zoom = d3.behavior.zoom()
            .on('zoom', this.doZoom());
        this.zoom.x(this.timeScale);
        this.svg
            .call(this.zoom)
            .call(this.zoom.event)
    };
    this.endZoom = function () {
        this.svg.on(".zoom", null);
    };

}

ZoomableLineChart.prototype = LineChart.prototype;
ZoomableLineChart.prototype.constructor = ZoomableLineChart;

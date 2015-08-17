// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery-2.1.3.min
//= require jquery_ujs
//= require jquery-ui.min
//= require turbolinks
//= require jquery.color-2.1.2.min
//= require jquery.datetimepicker
//= require d3.min
//= require moment
//= require jquery.qtip.min
//= require jquery.dataTables.min
//= require_tree ./common
//= require_tree ./web


function b64ToUint6 (nChr) {
    return nChr > 64 && nChr < 91 ? nChr - 65
        : nChr > 96 && nChr < 123 ? nChr - 71
        : nChr > 47 && nChr < 58 ? nChr + 4
        : nChr === 43 ? 62
        : nChr === 47 ? 63
        : 0;
}

function base64DecToArr (sBase64, nBlocksSize) {
    var
        sB64Enc = sBase64.replace(/[^A-Za-z0-9\+\/]/g, ""), nInLen = sB64Enc.length,
        nOutLen = nBlocksSize ? Math.ceil((nInLen * 3 + 1 >> 2) / nBlocksSize) * nBlocksSize : nInLen * 3 + 1 >> 2, taBytes = new Uint8Array(nOutLen);

    for (var nMod3, nMod4, nUint24 = 0, nOutIdx = 0, nInIdx = 0; nInIdx < nInLen; nInIdx++) {
        nMod4 = nInIdx & 3;
        nUint24 |= b64ToUint6(sB64Enc.charCodeAt(nInIdx)) << 6 * (3 - nMod4);
        if (nMod4 === 3 || nInLen - nInIdx === 1) {
            for (nMod3 = 0; nMod3 < 3 && nOutIdx < nOutLen; nMod3++, nOutIdx++) {
                taBytes[nOutIdx] = nUint24 >>> (16 >>> nMod3 & 24) & 255;
            }
            nUint24 = 0;

        }
    }
    return taBytes;
}

function decodeSensorTimeVal(base64Data) {
    data = base64DecToArr(base64Data);
    var arr = [];
    for(var i = 0; i<data.length; i++) {
        if(i%2 == 1) {
            arr.push(data[i]*256+data[i-1]);
        }
    }
    return arr;
}

var colorClasses = {
    "health": "bgc3",
    "medication": "bgc4"
};

function determineColor(point) {
    if (point.kind == 'start') {
        return "bgc0";
    } else if (point.kind == 'health') {
        return "bgc3";
    } else if (point.kind == 'medication') {
        return "bgc4";
    } else if (point.kind == 'activity') {
        return "bgc2";
    } else {
        return "";
    }

}

function determineImage(point) {
    if ( point.type == "blood_sugar") {
        return "blood_sugar";
    } else if ( point.type == "blood_pressure") {
        return "blood_pressure";
    } else if ( point.type == "insulin") {
        return "insulin";
    } else if ( point.type == "start") {
        return "start";
    } else if ( point.type == "cycling") {
        return "cycling";
    }
}

var historyData = [

    {
        "time": "2015/06/07",
        "history": [
            {
                "id": 0,
                "kind": "start",
                "type": "start"
            }
        ]
    },

    {
        "time": "2015/06/09",
        "history": [
            {
                "id": 1,
                "kind": "health",
                "type": "blood_sugar",
                "value": "12.7",
                "unit": "mmol/L"
            },            {
                "id": 1,
                "kind": "activity",
                "type": "cycling",
                "value": "1.5",
                "unit": "hr"
            },
            {
                "id": 2,
                "kind": "medication",
                "type": "insulin",
                "value": "22",
                "unit": "ml"
            }

        ]
    },

    {
        "time": "2015/06/11",
        "history": [
            {
                "id": 1,
                "kind": "health",
                "type": "blood_sugar",
                "value": "12.7",
                "unit": "mmol/L"
            },
            {
                "id": 1,
                "kind": "health",
                "type": "blood_pressure",
                "value": "120/80/60",
                "unit": ""
            },
            {
                "id": 2,
                "kind": "medication",
                "type": "insulin",
                "value": "22",
                "unit": "ml"
            }

        ]
    }
];

function countElements(history) {
    var count = 0;
    jQuery.each(history, function () {

        jQuery.each(this.history, function () {
            count++;
        });
    });
    return count;
}

function countElementBefore(history, A, B) {
    var a = 0;
    var b = 0;
    var count = 0;
    jQuery.each(history, function () {

        jQuery.each(this.history, function () {
            //  alert(" a: "+a+" b: "+b+" A: "+A+" B: "+B);
            if (a < A || (a==A && b < B)) {
                count++;
            }
            b++
        });
        a++;
        b = 0;
    });
    return count;
}

function getElement(history, a, b) {
    return history[a].history[b];
}

function computeLeft(history, w, a, b) {
    return w/(history.length+1)*(a+1) +b*55 - (history[a].history.length*55)/2;
}

function addPoint(canvas, length, history, a, b) {
    var w = $(canvas).width();
    var step = w / length;
    var count = countElements(history);
    var rareMode = length > count;

    if (rareMode) {
        step = w / (count + 1);
    }
    var left = computeLeft(history, w, a, b); //(countElementBefore(history, a, b) + 1) * step;
    var point = getElement(history, a, b);


    //  alert("W: " + w + " C: " + count + " S:" + step + " L: " + left + " " + point.value + " " + point.unit);



    return ( b == 0 ? "<div class='historyTime' style='left:"+left+"px'>"+history[a].time+"</div>" : "") + "<div class='historyItem " + determineColor(point) + "' style='left:" + left + "px'><div class='inner "+determineImage(point)+"'></div></div>";

}

function addPoints(canvas, history) {
    var LENGTH = 10;
    var a = 0;
    var b = 0;
    var lastb = 0;
    var w = $(canvas).width();
    var l = computeLeft(historyData, w, 0, 0);
    var pointsHTML = "";
    jQuery.each(history, function () {
        jQuery.each(this.history, function () {
            pointsHTML += addPoint(canvas, LENGTH, history, a, b);
            b++;
        });
        a++;
        lastb = b;
        b = 0;
    });
    var sl = computeLeft(history, w, 0, 0);
    var sw = computeLeft(historyData, w, a-1, lastb-1);

    pointsHTML = "<div class='historyLine' style='left:"+sl+"px;width:"+(sw-sl)+"px;"+"'></div>"+pointsHTML;

    pointsHTML += "<div style='clear:both;'></div>";
    $(canvas).html(pointsHTML);

}

(function() {

// Inspired by http://informationandvisualization.de/blog/box-plot
    d3.box = function() {
        var width = 1,
            height = 1,
            duration = 0,
            domain = null,
            value = Number,
            whiskers = boxWhiskers,
            quartiles = boxQuartiles,
            showLabels = true, // whether or not to show text labels
            showWhiskerLabels = false,
            leftLabel = false,
            numBars = 4,
            curBar = 1,
            tickFormat = null;

        // For each small multiple…
        function box(g) {
            g.each(function(data, i) {
                //d = d.map(value).sort(d3.ascending);
                //var boxIndex = data[0];
                //var boxIndex = 1;
                var d = data[1].sort(d3.ascending);

                // console.log(boxIndex);
                //console.log(d);

                var g = d3.select(this),
                    n = d.length,
                    min = d[0],
                    max = d[n - 1];

                // Compute quartiles. Must return exactly 3 elements.
                var quartileData = d.quartiles = quartiles(d);

                // Compute whiskers. Must return exactly 2 elements, or null.
                var whiskerIndices = whiskers && whiskers.call(this, d, i),
                    whiskerData = whiskerIndices && whiskerIndices.map(function(i) { return d[i]; });

                // Compute outliers. If no whiskers are specified, all data are "outliers".
                // We compute the outliers as indices, so that we can join across transitions!
                var outlierIndices = whiskerIndices
                    ? d3.range(0, whiskerIndices[0]).concat(d3.range(whiskerIndices[1] + 1, n))
                    : d3.range(n);

                // Compute the new x-scale.
                var x1 = d3.scale.linear()
                    .domain(domain && domain.call(this, d, i) || [min, max])
                    .range([height, 0]);

                // Retrieve the old x-scale, if this is an update.
                var x0 = this.__chart__ || d3.scale.linear()
                        .domain([0, Infinity])
                        // .domain([0, max])
                        .range(x1.range());

                // Stash the new scale.
                this.__chart__ = x1;

                // Note: the box, median, and box tick elements are fixed in number,
                // so we only have to handle enter and update. In contrast, the outliers
                // and other elements are variable, so we need to exit them! Variable
                // elements also fade in and out.

                // Update center line: the vertical line spanning the whiskers.
                var center = g.selectAll("line.center")
                    .data(whiskerData ? [whiskerData] : []);

                //vertical line
                center.enter().insert("line", "rect")
                    .attr("class", "center")
                    .attr("x1", width / 2)
                    .attr("y1", function(d) { return x0(d[0]); })
                    .attr("x2", width / 2)
                    .attr("y2", function(d) { return x0(d[1]); })
                    .style("opacity", 1e-6)
                    .transition()
                    .duration(duration)
                    .style("opacity", 1)
                    .attr("y1", function(d) { return x1(d[0]); })
                    .attr("y2", function(d) { return x1(d[1]); });

                center.transition()
                    .duration(duration)
                    .style("opacity", 1)
                    .attr("y1", function(d) { return x1(d[0]); })
                    .attr("y2", function(d) { return x1(d[1]); });

                center.exit().transition()
                    .duration(duration)
                    .style("opacity", 1e-6)
                    .attr("y1", function(d) { return x1(d[0]); })
                    .attr("y2", function(d) { return x1(d[1]); })
                    .remove();

                // Update innerquartile box.
                var box = g.selectAll("rect.box")
                    .data([quartileData]);

                box.enter().append("rect")
                    .attr("class", "box")
                    .attr("x", 0)
                    .attr("y", function(d) { return x0(d[2]); })
                    .attr("width", width)
                    .attr("height", function(d) { return x0(d[0]) - x0(d[2]); })
                    .transition()
                    .duration(duration)
                    .attr("y", function(d) { return x1(d[2]); })
                    .attr("height", function(d) { return x1(d[0]) - x1(d[2]); });

                box.transition()
                    .duration(duration)
                    .attr("y", function(d) { return x1(d[2]); })
                    .attr("height", function(d) { return x1(d[0]) - x1(d[2]); });

                // Update median line.
                var medianLine = g.selectAll("line.median")
                    .data([quartileData[1]]);

                medianLine.enter().append("line")
                    .attr("class", "median")
                    .attr("x1", 0)
                    .attr("y1", x0)
                    .attr("x2", width)
                    .attr("y2", x0)
                    .transition()
                    .duration(duration)
                    .attr("y1", x1)
                    .attr("y2", x1);

                medianLine.transition()
                    .duration(duration)
                    .attr("y1", x1)
                    .attr("y2", x1);

                // Update whiskers.
                var whisker = g.selectAll("line.whisker")
                    .data(whiskerData || []);

                whisker.enter().insert("line", "circle, text")
                    .attr("class", "whisker")
                    .attr("x1", 0)
                    .attr("y1", x0)
                    .attr("x2", 0 + width)
                    .attr("y2", x0)
                    .style("opacity", 1e-6)
                    .transition()
                    .duration(duration)
                    .attr("y1", x1)
                    .attr("y2", x1)
                    .style("opacity", 1);

                whisker.transition()
                    .duration(duration)
                    .attr("y1", x1)
                    .attr("y2", x1)
                    .style("opacity", 1);

                whisker.exit().transition()
                    .duration(duration)
                    .attr("y1", x1)
                    .attr("y2", x1)
                    .style("opacity", 1e-6)
                    .remove();

                // Update outliers.
                var outlier = g.selectAll("circle.outlier")
                    .data(outlierIndices, Number);

                outlier.enter().insert("circle", "text")
                    .attr("class", "outlier")
                    .attr("r", 5)
                    .attr("cx", width / 2)
                    .attr("cy", function(i) { return x0(d[i]); })
                    .style("opacity", 1e-6)
                    .transition()
                    .duration(duration)
                    .attr("cy", function(i) { return x1(d[i]); })
                    .style("opacity", 1);

                outlier.transition()
                    .duration(duration)
                    .attr("cy", function(i) { return x1(d[i]); })
                    .style("opacity", 1);

                outlier.exit().transition()
                    .duration(duration)
                    .attr("cy", function(i) { return x1(d[i]); })
                    .style("opacity", 1e-6)
                    .remove();

                // Compute the tick format.
                var format = tickFormat || x1.tickFormat(8);

                // Update box ticks.
                var boxTick = g.selectAll("text.box")
                    .data(quartileData);
                if(showLabels == true) {
                    boxTick.enter().append("text")
                        .attr("class", "box")
                        .attr("dy", ".3em")
                        .attr("dx", function(d, i) { return leftLabel ? 6 : -6 })
                        .attr("x", function(d, i) { return leftLabel ?  + width : 0 })
                        .attr("y", x0)
                        .attr("text-anchor", function(d, i) { return leftLabel ? "start" : "end"; })
                        .text(format)
                        .transition()
                        .duration(duration)
                        .attr("y", x1);
                }

                boxTick.transition()
                    .duration(duration)
                    .text(format)
                    .attr("y", x1);

                // Update whisker ticks. These are handled separately from the box
                // ticks because they may or may not exist, and we want don't want
                // to join box ticks pre-transition with whisker ticks post-.
                var whiskerTick = g.selectAll("text.whisker")
                    .data(whiskerData || []);
                if(showWhiskerLabels == true) {
                    whiskerTick.enter().append("text")
                        .attr("class", "whisker")
                        .attr("dy", ".3em")
                        .attr("dx", 6)
                        .attr("x", width)
                        .attr("y", x0)
                        .text(format)
                        .style("opacity", 1e-6)
                        .transition()
                        .duration(duration)
                        .attr("y", x1)
                        .style("opacity", 1);
                }
                whiskerTick.transition()
                    .duration(duration)
                    .text(format)
                    .attr("y", x1)
                    .style("opacity", 1);

                whiskerTick.exit().transition()
                    .duration(duration)
                    .attr("y", x1)
                    .style("opacity", 1e-6)
                    .remove();
            });
            d3.timer.flush();
        }

        box.leftLabel = function(x) {
            if (!arguments.length) return leftLabel;
            leftLabel = x;
            return box;
        };

        box.width = function(x) {
            if (!arguments.length) return width;
            width = x;
            return box;
        };

        box.height = function(x) {
            if (!arguments.length) return height;
            height = x;
            return box;
        };

        box.tickFormat = function(x) {
            if (!arguments.length) return tickFormat;
            tickFormat = x;
            return box;
        };

        box.duration = function(x) {
            if (!arguments.length) return duration;
            duration = x;
            return box;
        };

        box.domain = function(x) {
            if (!arguments.length) return domain;
            domain = x == null ? x : d3.functor(x);
            return box;
        };

        box.value = function(x) {
            if (!arguments.length) return value;
            value = x;
            return box;
        };

        box.whiskers = function(x) {
            if (!arguments.length) return whiskers;
            whiskers = x;
            return box;
        };

        box.showLabels = function(x) {
            if (!arguments.length) return showLabels;
            showLabels = x;
            return box;
        };

        box.quartiles = function(x) {
            if (!arguments.length) return quartiles;
            quartiles = x;
            return box;
        };

        return box;
    };

    function boxWhiskers(d) {
        return [0, d.length - 1];
    }

    function boxQuartiles(d) {
        return [
            d3.quantile(d, .25),
            d3.quantile(d, .5),
            d3.quantile(d, .75)
        ];
    }

})();


function iqr(k) {
    return function(d, i) {
        var q1 = d.quartiles[0],
            q3 = d.quartiles[2],
            iqr = (q3 - q1) * k,
            i = -1,
            j = d.length;
        while (d[++i] < q1 - iqr);
        while (d[--j] > q3 + iqr);
        return [i, j];
    };
}

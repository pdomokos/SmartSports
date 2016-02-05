

var colorClasses = {
    "health": "bgc3",
    "medication": "bgc4"
};

function determineColor(point) {
    var m = {
        start: "dashboardBgColor",
        health: "healthBgColor",
        medication: "medicationBgColor",
        exercise: "exerciseBgColor",
        wellbeing: "wellbeingBgColor",
        diet: "dietBgColor"
    };
    if($.inArray(point.kind, Object.keys(m)) ) {
        return m[point.kind]
    }
    return "dashboardBgColor";
}

function determineImage(point) {
    var m = {
        start: "startType",
        blood_pressure: "bloodPressureType",
        blood_sugar: "bloodSugarType",
        weight: "weightType",
        cycling: "cyclingType",
        steps: "stepsType",
        insulin: "insulinType",
        drug: "drugType",
        sleep: "sleepType",
        drink: "drinkType",
        food: "foodType"
    };
    ret = "";
    if($.inArray(point.type, Object.keys(m))) {
        ret = m[point.type];
    }
    return ret;
}
function determineTooltip(point) {
    var tt = point['date']+"<br/>"+point['tooltip'];
    return tt;
}
function convertToHistory(data) {
    var adata = data.filter(function(d) {return d['evt_type']!= 'waist';});
    var amap = {};
    var k = new Set(adata.map(function (p) {
        return moment(p['dates'][0]).format(moment_date2fmt)
    }));
    k.forEach(function (v) {
        amap[v] = []
    });
    adata.forEach(function (p) {
        amap[moment(p['dates'][0]).format(moment_date2fmt)].push(p)
    });
    var result = [];
    var dateKeys = Object.keys(amap);
    dateKeys.sort();
    dateKeys.forEach(function (currKey) {
        var ret = {};
        ret['time'] = currKey;
        ret['history'] = amap[currKey].map(function (aval) {
            var ret2 = {};
            ret2['kind'] = aval['kind'];
            ret2['type'] = aval['evt_type'];
            ret2['tooltip'] = aval['tooltip'];
            ret2['date'] = moment(aval['dates'][0]).format(moment_fmt);
            return ret2;
        });
        result.push(ret);
    });
    return result;
}
var historyData = [

    {
        "time": "2015/06/06",
        "history": [
            {
                "kind": "start",
                "type": "start"
            },
            {
                "kind": "start",
                "type": "start"
            }
        ]
    },
    {
        "time": "2015/06/07",
        "history": [
            {
                "kind": "start",
                "type": "start"
            },
            {
                "kind": "start",
                "type": "start"
            },
            {
                "kind": "start",
                "type": "start"
            },
            {
                "kind": "health",
                "type": "blood_sugar",
                "value": "12.7",
                "unit": "mmol/L"
            },
            {
                "kind": "health",
                "type": "blood_sugar",
                "value": "12.7",
                "unit": "mmol/L"
            }
        ]
    },

    {
        "time": "2015/06/09",
        "history": [
            {
                "kind": "health",
                "type": "blood_sugar",
                "value": "12.7",
                "unit": "mmol/L"
            },            {
                "kind": "activity",
                "type": "cycling",
                "value": "1.5",
                "unit": "hr"
            },
            {
                "kind": "activity",
                "type": "cycling",
                "value": "1.5",
                "unit": "hr"
            },
            {
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
                "kind": "health",
                "type": "blood_sugar",
                "value": "12.7",
                "unit": "mmol/L"
            },
            {
                "kind": "health",
                "type": "blood_pressure",
                "value": "120/80/60",
                "unit": ""
            },
            {
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



    return ( b == 0 ? "<div class='historyTime' style='left:"+left+"px'>"+history[a].time+"</div>" : "") +
        "<div class='historyItem " + determineColor(point) +
        "' style='left:" + left + "px'><div class='inner "+
        determineImage(point)+"' title='"+determineTooltip(point)+"'></div></div>";

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
    $(canvas+" .inner").qtip()

}

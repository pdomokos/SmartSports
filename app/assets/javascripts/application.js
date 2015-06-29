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



    return ( b == 0 ? "<div class='historyTime' style='left:"+left+"px'>"+history[a].time+"</div>" : "") + "<div class='history_item " + determineColor(point) + "' style='left:" + left + "px'><div class='inner "+determineImage(point)+"'></div></div>";

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
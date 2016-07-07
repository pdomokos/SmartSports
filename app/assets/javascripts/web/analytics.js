function analytics_loaded() {
    var self = this;
    var chartElement = $("#bg-container")[0];
    var uid = chartElement.dataset.uid;

    $("div.appMenu button").removeClass("selected");
    $("#analytics-link").css({background: "rgba(240, 108, 66, 0.3)"});

    var user_lang = $("#user-lang")[0].value;
    if (!user_lang) {
        user_lang = 'hu';
    }
    $('#timeline_datepicker').datetimepicker({
        format: 'Y-m-d',
        timepicker: false,
        lang: user_lang,
        onSelectDate: function (ct, input) {
            console.log("timeline date selected");
            self.timeline.update(moment(ct).format(moment_datefmt));
            input.datetimepicker('hide')
        },
        todayButton: true
    });

    d3.json(urlPrefix() + "users/" + uid + "/measurements.json?meas_type=blood_sugar", draw_bg_data);
}

function draw_bg_data(jsondata) {
    var data = {};
    var grp_map = {};
    grp_map[48] = "Unspecified";
    grp_map[58] = "Pre Breakfast";
    grp_map[60] = "Pre Lunch";
    grp_map[62] = "Pre Supper";
    data['blood_glucose'] = $.map(jsondata, function (d) {
            return {date: d.date, value: d.blood_sugar, group: grp_map[d.blood_sugar_time]}
        }
    );
    var bgdata = data['blood_glucose'];
    console.log(bgdata[bgdata.length - 1]);
    var chartParams = {
        rightLabel: "mmol/L"
    };
    var chartElement = $("#bg-container")[0];
    var uid = chartElement.dataset.uid;
    bg_trend_chart = new LineChart("bg-container", data, chartParams, chartElement.dataset.bgmin, chartElement.dataset.bgmax);
    bg_trend_chart.cb_over = function (d, elem, chart) {
        d3.select(elem)
            .transition()
            .attr("r", chart.selectedR);
    };
    bg_trend_chart.cb_out = function (d, elem, chart) {
        d3.select(elem)
            .transition()
            .attr("r", chart.baseR);
    };
    bg_trend_chart.cb_click = function (d, elem, chart) {
        console.log("selected: ");
        console.log(d);

        var dateToShow = moment(d.date).format(moment_datefmt);
        $("#timeline-date").html(dateToShow);
        var timeline = new TimelinePlot(uid, "analysis_data", "Daily timeline", {period: "daily"});
        timeline.f = moment(d.date).subtract(8, 'hours').format(moment_fmt);
        timeline.t = moment(d.date).add(1, 'minutes').format(moment_fmt);
        timeline.bgmin = chartElement.dataset.bgmin;
        timeline.bgmax = chartElement.dataset.bgmax;
        timeline.draw("div.timelineChart");
    };
    bg_trend_chart.draw();

    var dateToShow = moment(bgdata[bgdata.length - 1].date).format(moment_datefmt);
    var timeline = new TimelinePlot(uid, "analysis_data", "Daily timeline", {period: "daily"});
    timeline.bgmin = chartElement.dataset.bgmin;
    timeline.bgmax = chartElement.dataset.bgmax;
    timeline.date = dateToShow;
    timeline.draw("div.timelineChart");
}
@initTimelineDatepicker = (uid) ->
  $('#timeline_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    onSelectDate: (ct, input) ->
      console.log("timeline date selected")
      input.datetimepicker('hide')
      dateToShow = moment(ct).format("YYYY-MM-DD")
      setTimelineTitle(dateToShow)
      d3.json("/users/"+uid+"/analysis_data.json?date="+dateToShow+"&weekly=true", timeline_data_received)
    todayButton: true
  })

@setTimelineTitle = (date) ->
  a = moment(date).startOf('week').format(moment_fmt)
  b = moment(date).endOf('week').format(moment_fmt)
  $("div.timeline-title").html("Weekly timeline ("+a+" - "+b+")")


@timeline_data_received = (jsondata) ->
  console.log "drawing timeline"
  console.log jsondata

  events = $.map(jsondata, (evt, index)->
    console.log evt
    if evt.dates
      evt.dates =[new Date(evt.dates[0]), new Date(evt.dates[1])]
    return evt
  )
  $("#timeline").html("")
  timeline = new TimeLine("#timeline", events , @dateToShow);
  timeline.draw()
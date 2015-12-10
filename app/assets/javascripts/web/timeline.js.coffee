@initTimelineDatepicker = (uid) ->
  $('#timeline_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
      self.dateToShow = moment(ct).format("YYYY-MM-DD")
      d3.json("/users/"+uid+"/analysis_data.json?date="+self.dateToShow, timeline_data_received)
    todayButton: true
  })

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
@analytics2_loaded = () ->
  uid = $("#current-user-id")[0].value
  @dateToShow = moment().format("YYYY-MM-DD")
#  @dateToShow = "2015-05-29"
  d3.json("/users/"+uid+"/analysis_data.json?date="+@dateToShow, act_data_received)

act_data_received = (jsondata) ->
  console.log "daily activities"
  console.log jsondata

  events = $.map(jsondata, (evt, index)->
#    evt = {}
#    evt.id = "act-"+act.id
#    evt.title = act.activity_name
#    evt.dates =[new Date(act.start_time), new Date(act.end_time)]
#    evt.depth = index

    console.log evt
    evt.dates =[new Date(evt.dates[0]), new Date(evt.dates[1])]

    return evt
  )

  timeline = new TimeLine("#timeline", events , @dateToShow);
  timeline.draw()

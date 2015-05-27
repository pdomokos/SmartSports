@analytics2_loaded = () ->
  uid = $("#current-user-id")[0].value
#  dateToShow = moment().format("YYYY-MM-DD")
  @dateToShow = "2015-05-26"
  d3.json("/users/"+uid+"/activities.json?date="+dateToShow, act_data_received)

act_data_received = (jsondata) ->
  console.log "daily activities"
  console.log jsondata

  events = $.map(jsondata, (act, index)->
    evt = {}
    evt.id = "act-"+act.id
    evt.title = act.activity_name
    evt.dates =[new Date(act.start_time), new Date(act.end_time)]
    evt.depth = index
    return evt
  )
  console.log(dateToShow)
  timeline = new TimeLine("#timeline", events, @dateToShow);
  timeline.draw()

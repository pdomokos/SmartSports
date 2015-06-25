@explore_loaded = () ->
  self = this
  console.log "explore loaded"
  $("#sensorDataTable").on("click", "button.tableControl", show_sensor)
  uid = $("#current-user-id")[0].value
  s = getParameterByName("sid")
  console.log "s="+s
  if s!=""
    do_show(uid, s)

@getParameterByName = (name) ->
  name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
  regex = new RegExp("[\\?&]" + name + "=([^&#]*)")
  results = regex.exec(location.search)
  if results == null
    return ""
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "))

@show_sensor = (event) ->
  console.log "show: "
  console.log event.currentTarget.id

  arr = event.currentTarget.id.split("-")
  sid = arr[arr.length-1]
  uid = $("#current-user-id")[0].value

  if event.metaKey
    window.open("/users/"+uid+"/sensor_measurements/"+sid+"/edit", "_blank")
    return

  do_show(uid, sid)

@do_show = (uid, sid) ->
  $("div.sensorTable tr").removeClass("selectedRow")
  $("div.sensorTable tr#sensor-meas-"+sid).addClass("selectedRow")

  url = '/users/' + uid + '/sensor_measurements/'+sid+'.json'

  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent activities AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent activities  Successful AJAX call"
      console.log textStatus

      $("#sensor-data-group").html(data['group']+" data ("+moment(data['start_time']).format("YYYY-MM-DD hh:mm:ss")+")")
      rr_values = decodeSensorTimeVal(data['rr_data'])
      start = data['start_time']
      curr = Date.parse(start)
      rr_data = [{time: curr, value: rr_values[0]}]
      for rr in rr_values
        curr += rr
        rr_data.push({time: curr, value: rr})
      console.log "sid = "+sid+" duration (sec): "+(rr_data[rr_data.length-1]['time'] - rr_data[0]['time'])/1000.0

      cr_data = null
      speed_data = null

      cr_values = decodeSensorTimeVal(data['cr_data'])
      curr = Date.parse(start)
      cr_prev = 0
      speed_prev = 0
      curr_dt = 0

      if data['version'] =='1.1'
        if data['cr_data'] && data['cr_data']!=""
          console.log "adding speed data"
          cr_data = [{time: curr, value: cr_prev}]
          speed_data = [{time: curr, value: speed_prev}]

          for i in [0..cr_values.length-1]
            if (i % 3) == 0
              curr += cr_values[i]
            else if (i%3)==1
              cr_prev = cr_values[i]
            else
              cr_data.push({time: curr, value: cr_prev})
              speed_data.push({time: curr, value: cr_values[i]})
      else
        if data['cr_data'] && data['cr_data']!=""
          cr_data = [{time: curr, value: cr_prev}]
          for i in [0..cr_values.length-1]
            if i % 2 == 0
              curr += cr_values[i]
              curr_dt = cr_values[i]
            else
              cr_data.push({time: curr, value: (cr_values[i]-cr_prev)*6000.0/curr_dt})
              cr_prev = cr_values[i]

      hr_data = null
      if data['hr_data'] && data['hr_data']!=""
        hr_values = decodeSensorTimeVal(data['hr_data'])
        curr = Date.parse(start)
        hr_data = [{time: curr, value: 0}]
        for i in [0..hr_values.length-1]
          if i % 2 == 0
            curr += hr_values[i]
          else
            hr_data.push({time: curr, value: hr_values[i]})

      rr_chart = new RRChart("sensordata", rr_data, hr_data, cr_data, speed_data)
      # rr_chart.margin = {top: 20, right: 50, bottom: 20, left: 35}
      rr_chart.draw()

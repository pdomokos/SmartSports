@explore_loaded = () ->
  console.log "explore loaded"
  $("#sensorDataTable").on("click", "button.tableControl", show_sensor)

@show_sensor = (event) ->
  console.log "show: "
  console.log event.currentTarget.id

  $("div.sensorTable tr").removeClass("selectedRow")
  event.currentTarget.parentNode.parentNode.classList.add("selectedRow")

  arr = event.currentTarget.id.split("-")
  sid = arr[arr.length-1]
  uid = $("#current-user-id")[0].value
  url = '/users/' + uid + '/sensor_measurements/'+sid+'.json'

  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent activities AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent activities  Successful AJAX call"
      console.log textStatus

      rr_values = decodeSensorTimeVal(data['rr_data'])
      start = data['start_time']
      curr = Date.parse(start)
      rr_data = [{time: curr, value: rr_values[0]}]
      for rr in rr_values
        curr += rr
        rr_data.push({time: curr, value: rr})

      cr_data = null
      if data['cr_data'] && data['cr_data']!=""
        cr_values = decodeSensorTimeVal(data['cr_data'])
        console.log cr_values
        curr = Date.parse(start)
        cr_prev = 0
        curr_dt = 0
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
        console.log hr_values
        curr = Date.parse(start)
        hr_data = [{time: curr, value: 0}]
        for i in [0..hr_values.length-1]
          if i % 2 == 0
            curr += hr_values[i]
          else
            hr_data.push({time: curr, value: hr_values[i]})

      rr_chart = new RRChart("sensordata", rr_data, hr_data, cr_data)
      # rr_chart.margin = {top: 20, right: 50, bottom: 20, left: 35}
      rr_chart.draw()

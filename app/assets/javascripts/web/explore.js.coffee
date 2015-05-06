@explore_loaded = () ->
  console.log "explore loaded"
  uid = $("#current-user-id")[0].value
  url = '/users/' + uid + '/sensor_measurements/20.json'

  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent activities AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent activities  Successful AJAX call"
      console.log textStatus

      rr_values = decodeSensorTimeVal(data['rr_data'])
      chart_data = [{time: 0, rr: rr_values[0]}]
      curr = 0
      for rr in rr_values
        curr += rr
        chart_data.push({time: curr, rr: rr})

      rr_chart = new RRChart("sensordata", chart_data)
      # rr_chart.margin = {top: 20, right: 50, bottom: 20, left: 35}
      rr_chart.draw()
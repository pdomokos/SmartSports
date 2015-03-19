@wellbeing_loaded = () ->
  uid = $("#current-user-id")[0].value

  $("div.appMenu button").removeClass("selected")
  $("#wellbeing-button").addClass("selected")

  $('#sleep_scale').watermark('Quality of sleep, e.g. 60')
  $('#stress_scale').watermark('Stressfull day, e.g. 60')

  $('#sleep_start_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })
  $('#sleep_end_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })

  $('#stress_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })

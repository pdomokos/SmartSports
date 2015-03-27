@health_loaded = () ->

  uid = $("#current-user-id")[0].value

  $("div.appMenu button").removeClass("selected")
  $("#health-button").addClass("selected")

  $('#bloodpressure_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })
  $('#bloodsugar_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })
  $('#weight_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })
  $('#waist_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })

  init_meas()

#  console.log "getting health data for user:"+uid
#  meas_summary_url = "/users/" + uid + "/measurements.json?summary=true"
#  d3.json(meas_summary_url, draw_trend)
#
#  d = new Date()
#  d.setDate(d.getDate()-31)
#  day_2week = fmt(d)
#  actions_lastweek_url = "/users/" + uid + "/measurements.json?start="+day_2week
#  d3.json(actions_lastweek_url, draw_detail)

draw_trend = (data) ->

  heart_trend_chart = new TrendChart("heart-trend", data,
    ["systolicbp", "pulse", "diastolicbp"],
    ["SYS", "HR", "DIA"],
    ["left", "left", "right"]
    ["colset4_0", "colset4_1", "colset4_2"],
    ["mmHg", "1/min"],
    false
    )
  heart_trend_chart.margin = {top: 20, right: 45, bottom: 20, left: 30}
  heart_trend_chart.draw()

draw_detail = (data) ->

  heart_chart = new TrendChart("heartrate", data,
    ["pulse", "SPO2"],
    ["HR", "SPO2"],
    ["left", "right"]
    ["colset6_1", "colset6_2"],
    ["1/minutes", "SPO2%"],
    false,
    4.0/7
  )
  heart_chart.margin = {top: 20, right: 50, bottom: 20, left: 30}
  heart_chart.tick_unit = d3.time.day
  heart_chart.ticks = 4
  heart_chart.draw()

  blood_chart = new TrendChart("bloodsugar", data,
    ["blood_sugar", "waist"],
    ["Blood Glucose", "Waist"],
    ["left", "right"]
    ["colset6_1", "colset6_2"],
    ["mmol/L", "cm"],
    false,
      4.0/7
  )
  blood_chart.margin = {top: 20, right: 30, bottom: 20, left: 45}
  blood_chart.tick_unit = d3.time.day
  blood_chart.ticks = 4
  blood_chart.draw()

@init_meas = () ->
  console.log "init meas"

  $('#bp_sys').watermark('Systolic, eg: 120')
  $('#bp_dia').watermark('Diastolic, eg: 80')
  $('#bp_hr').watermark('Heart rate, eg: 60')
  $('#glucose').watermark('Blood Sugar, eg: 6.3')
  $('#weight').watermark('Body Weight, eg: 72')
  $('#waist').watermark('Waist, eg: 63')
  $('#bp_sys').focus()


  $("form.resource-create-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log e
    console.log xhr.responseText
    $("#"+form_id+" input.dataFormField").val("")

    load_meas()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create measurement.")
  )

  $("#recentMeasTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    load_meas()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

@load_meas = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent meas"
  $.ajax '/users/' + current_user + '/measurements.js?source='+window.default_source+'&order=desc&limit=4',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent measurements AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent measurements  Successful AJAX call"
      console.log textStatus

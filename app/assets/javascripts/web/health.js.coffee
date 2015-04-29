@health_loaded = () ->

  uid = $("#current-user-id")[0].value

  $("div.appMenu button").removeClass("selected")
  $("#health-button").addClass("selected")

  $('#bloodpressure_datepicker').datetimepicker(timepicker_defaults)
  $('#bloodsugar_datepicker').datetimepicker(timepicker_defaults)
  $('#weight_datepicker').datetimepicker(timepicker_defaults)
  $('#waist_datepicker').datetimepicker(timepicker_defaults)

  init_meas()
  loadHealthHistory()

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


  $("form.resource-create-form.health-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    $("#"+form_id+" input.dataFormField").val("")

    $('#bloodpressure_datepicker').val(moment().format(moment_fmt))
    $('#bloodsugar_datepicker').val(moment().format(moment_fmt))
    $('#weight_datepicker').val(moment().format(moment_fmt))
    $('#waist_datepicker').val(moment().format(moment_fmt))

    loadHealthHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create measurement.")
  )

  $("#recentMeasTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    loadHealthHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

  $('.hisTitle').click ->
    loadHealthHistory()

  $(".favTitle").click ->
    load_meas(true)
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

  $("#recentMeasTable").on("click", "td.measItem", (e) ->
    console.log "loading measurement"
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    console.log data
    if(data.meas_type=="blood_pressure")
      $("#bp_sys").val(data.systolicbp)
      $("#bp_dia").val(data.diastolicbp)
      $("#bp_hr").val(data.pulse)
    else if(data.meas_type=="blood_sugar")
      $("#glucose").val(data.blood_sugar)
    else if(data.meas_type=="weight")
      $("#weight").val(data.weight)
    else if(data.meas_type=="waist")
      $("#waist").val(data.waist)
  )

@loadHealthHistory = () ->
  load_meas()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@load_meas = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent meas"
  url = '/users/' + current_user + '/measurements.js?source='+window.default_source+'&order=desc&limit=10'
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent measurements AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent measurements  Successful AJAX call"
      console.log textStatus

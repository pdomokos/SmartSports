@health_loaded = () ->
  uid = $("#current-user-id")[0].value
  popup_messages = JSON.parse($("#popup-messages").val())

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#health-link").addClass("selected")

  $('#bloodpressure_datepicker').datetimepicker(timepicker_defaults)
  $('#bloodsugar_datepicker').datetimepicker(timepicker_defaults)
  $('#weight_datepicker').datetimepicker(timepicker_defaults)
  $('#waist_datepicker').datetimepicker(timepicker_defaults)

  $("#bp-create-form button").click ->
    if( (isempty("#bp_sys") && isempty("#bp_dia") && isempty("#bp_hr")) ||
        (!isempty("#bp_sys") && isempty("#bp_dia")) ||
        (isempty("#bp_sys") && !isempty("#bp_dia")) ||
        (notpositive("#bp_sys") || notpositive("#bp_dia") || notpositive("#bp_hr")))
      popup_error(popup_messages.invalid_health_hr)
      return false

  $("#bg-create-form button").click ->
    if isempty("#glucose") || notpositive("#glucose")
      popup_error(popup_messages.invalid_health_bg)
      return false
  $("#weight-create-form button").click ->
    if isempty("#weight")|| notpositive("#weight")
      popup_error(popup_messages.invalid_health_wd)
      return false
  $("#waist-create-form button").click ->
    if isempty("#waist")|| notpositive("#waist")
      popup_error(popup_messages.invalid_health_cd)
      return false
  init_meas()
  loadHealthHistory()

@init_meas = () ->
  console.log "init meas"
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
    popup_success(popup_messages.save_success)
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    console.log error
    popup_error(popup_messages.failed_to_add_data)
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
  lang = $("#data-lang-health")[0].value
  url = '/users/' + current_user + '/measurements.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent measurements AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      if fav
        $(".deleteMeas").addClass("hidden")
      else
        $(".deleteMeas").removeClass("hidden")
      console.log "load recent measurements  Successful AJAX call"
      console.log textStatus

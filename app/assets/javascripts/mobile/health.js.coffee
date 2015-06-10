@health_loaded = () ->
  console.log 'health loaded'
  $("#health-link").css
    background: "rgba(137, 130, 200, 0.3)"

  $('#bloodpressure_datepicker').datetimepicker(timepicker_defaults)
  $('#bloodsugar_datepicker').datetimepicker(timepicker_defaults)
  $('#weight_datepicker').datetimepicker(timepicker_defaults)
  $('#waist_datepicker').datetimepicker(timepicker_defaults)

#  $("#bp-create-form button").click ->
#  if( (isempty("#bp_sys") && isempty("#bp_dia") && isempty("#bp_hr")) ||
#      (!isempty("#bp_sys") && isempty("#bp_dia")) ||
#      (isempty("#bp_sys") && !isempty("#bp_dia")) ||
#      (notpositive("#bp_sys") || notpositive("#bp_dia") || notpositive("#bp_hr")))
#    $("#failureHealthPopup").popup("open")
#    return false
#
#  $("#bg-create-form button").click ->
#    if isempty("#glucose") || notpositive("#glucose")
#      $("#failureHealthPopup").popup("open")
#      return false
#
#  $("#weight-create-form button").click ->
#    if isempty("#weight")|| notpositive("#weight")
#      $("#failureHealthPopup").popup("open")
#      return false
#
#  $("#waist-create-form button").click ->
#    if isempty("#waist")|| notpositive("#waist")
#      $("#failureHealthPopup").popup("open")
#      return false
  init_meas()
  load_meas()

@init_meas = () ->
  console.log "init meas"
  $('#bp_sys').focus()

  $(document).on("ajax:success", "form.resource-create-form.health-form", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    $("#"+form_id+" input.dataFormField").val("")

    $('#bloodpressure_datepicker').val(moment().format(moment_fmt))
    $('#bloodsugar_datepicker').val(moment().format(moment_fmt))
    $('#weight_datepicker').val(moment().format(moment_fmt))
    $('#waist_datepicker').val(moment().format(moment_fmt))

    load_meas()
    $("#successHealthPopup").popup("open")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    console.log error
    $("#failureHealthPopup").popup("open")
  )

  $(document).on("ajax:success", "#updateMeasForm", (e, data, status, xhr) ->
    console.log("update successfull")
    $("#healthPage").attr("data-scrolltotable", true)
    $( ":mobile-pagecontainer" ).pagecontainer("change", "#healthPage")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to update meas.")
  )
  $(document).on("ajax:success", "#deleteMeasForm", (e, data, status, xhr) ->
    console.log("delete successfull")
    $("#healthPage").attr("data-scrolltotable", true)
    $.mobile.navigate( "#healthPage" )
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete meas.")
  )

  $("#healthPage").on("click" , "#healthListView td.meas_item", load_meas_item)

  $('#hist-health-button').click ->
    load_meas()

  $("#fav-health-button").click ->
    load_meas(true)

  $(document).on("pagecontainershow", (event, ui) ->
    console.log("health pagecontainershow")
    load_meas()
  )

load_meas_item = (e) ->
  console.log "loading measurement"
  data = JSON.parse(e.currentTarget.querySelector("input").value)
  console.log data
  if(data.meas_type=="blood_pressure")
    $("#bp_sys").val(data.systolicbp)
    $("#bp_dia").val(data.diastolicbp)
    $("#bp_hr").val(data.pulse)
  else if(data.meas_type=="blood_sugar")
    $("#bs_glucose").val(data.blood_sugar)
  else if(data.meas_type=="weight")
    $("#b_weight").val(data.weight)
  else if(data.meas_type=="waist")
    $("#b_waist").val(data.waist)


@load_meas = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent meas"
  #lang = $("#data-lang-health")[0].value
  url = '/users/' + current_user + '/measurements.js?source='+window.default_source+'&order=desc&limit=10&mobile=true'
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent measurements AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      if fav
        $("#hist-button").removeClass("ui-btn-active")
        $("#fav-button").addClass("ui-btn-active")
      else
        $("#hist-button").addClass("ui-btn-active")
        $("#fav-button").removeClass("ui-btn-active")
      if $("#healthPage").attr('data-scrolltotable')
        $.mobile.silentScroll($("div.ui-navbar").offset().top)
        $("#healthPage").attr('data-scrolltotable', null)
      console.log "load recent measurements  Successful AJAX call"
      console.log textStatus

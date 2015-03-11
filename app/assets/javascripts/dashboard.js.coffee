
@dashboard_loaded = (is_mobile=false) ->
  console.log "dashboard loaded"

  $('#bp_sys').watermark('Systolic, eg: 120')
  $('#bp_dia').watermark('Diastolic, eg: 80')
  $('#bp_hr').watermark('Heart rate, eg: 60')
  $('#glucose').watermark('Blood Sugar, eg: 6.3')
  $('#weight').watermark('Body Weight, eg: 72')
  $('#waist').watermark('Waist, eg: 63')
  $('#bp_sys').focus()
  $("div.appMenu button").removeClass("selected")
  $("#dashboard-button").addClass("selected")

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
  $.ajax '/users/' + current_user + '/measurements.js?source=smartsport&order=desc&limit=4',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent measurements AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent measurements  Successful AJAX call"
      console.log textStatus


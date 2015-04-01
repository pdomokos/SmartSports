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
    "format": "YYYY-MM-DD"
  })

  $("form.resource-create-form.lifestyle-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log e
    console.log xhr.responseText
    $("#"+form_id+" input.dataFormField").val("")

    load_lifestyles()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create diet.")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    load_lifestyles()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

@load_lifestyles = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent diets"
  $.ajax '/users/' + current_user + '/lifestyles.js?source='+window.default_source+'&order=desc&limit=4',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent diets  Successful AJAX call"
      console.log textStatus

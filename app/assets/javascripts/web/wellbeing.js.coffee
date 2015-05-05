@wellbeing_loaded = () ->
  uid = $("#current-user-id")[0].value

  $("div.appMenu button").removeClass("selected")
  $("#wellbeing-button").addClass("selected")

  $("#sleep_amount").val(50)
  $("#stress_amount").val(50)

  $('#sleep_start_datepicker').datetimepicker(timepicker_defaults)
  $('#sleep_end_datepicker').datetimepicker(timepicker_defaults)
  load_lifestyles()

  $('#stress_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $("#sleep_scale").slider({
    min: 0,
    max: 100,
    value: 50
  }).slider({
    slide: (event, ui) ->
      $("#sleep_percent").html(ui.value+"%")
    change: (event, ui) ->
      $("#sleep_amount").val(ui.value)
  })

  $("#stress_scale").slider({
    min: 0,
    max: 100,
    value: 50
  }).slider({
    slide: (event, ui) ->
      $("#stress_percent").html(ui.value+"%")
    change: (event, ui) ->
      $("#stress_amount").val(ui.value)
  })

  $("form.resource-create-form.lifestyle-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    load_lifestyles()
  ).on("ajax:error", (e, xhr, status, error) ->
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

  $('.hisTitle').click ->
    load_lifestyles()

  $("#recentResourcesTable").on("click", "td.lifestyleItem", (e) ->
    console.log "loading lifestyle"
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    console.log data
    if(data.group=="sleep")
      $("#sleep_amount").val(data.amount)
      $("#sleep_percent").html(data.amount+"%")
      $("#sleep_scale").slider({value: data.amount})
    else if(data.group=="stress")
      $("#stress_amount").val(data.amount)
      $("#stress_percent").html(data.amount+"%")
      $("#stress_scale").slider({value: data.amount})
  )

@load_lifestyles = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent lifestyles"
  $.ajax '/users/' + current_user + '/lifestyles.js?source='+window.default_source+'&order=desc&limit=10',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent diets AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log textStatus

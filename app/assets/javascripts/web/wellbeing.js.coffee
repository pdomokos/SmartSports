@wellbeing_loaded = () ->
  uid = $("#current-user-id")[0].value

  $("div.appMenu button").removeClass("selected")
  $("#wellbeing-button").addClass("selected")

  $("#sleep_amount").val(2)
  $("#stress_amount").val(1)

  $('#sleep_start_datepicker').datetimepicker(timepicker_defaults)
  $('#sleep_end_datepicker').datetimepicker(timepicker_defaults)
  $('#pain_start_datepicker').datetimepicker(timepicker_defaults)
  $('#pain_end_datepicker').datetimepicker(timepicker_defaults)
  $('#periods_start_datepicker').datetimepicker(timepicker_defaults)
  $('#periods_end_datepicker').datetimepicker(timepicker_defaults)

  sleepList = ["Very bad", "Fairly bad", "Fairly good", "Very good"]
  stressList = ["Below average", "Average", "Medium", "High"]
  illnessList = ["Slight mild", "Mild", "Moderate", "Severe", "More severe"]
  painList = ["Slight mild", "Mild", "Moderate", "Severe", "Worst possible pain"]
  periodPainList = ["No pain","Mild pain","Moderate pain","Severe pain","Very painful"]
  periodVolumeList = ["Light", "Moderate", "Strong", "Quite heavy","Heavy"]
  painTypeList = ["Acute","Nociceptive","Neuropathic(central)","Neuropathic(peripheral)","Visceral","Mixed"]

  load_lifestyles()
  load_illness_types()

  $("#pain_name").autocomplete({
    minLength: 0,
    source: painTypeList
  }).focus ->
    $(this).autocomplete("search")

  $('#stress_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('#illness_start_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('#illness_end_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $("#sleep_scale").slider({
    min: 0,
    max: 3,
    value: 2
  }).slider({
    slide: (event, ui) ->
        $("#sleep_percent").html(sleepList[ui.value])
    change: (event, ui) ->
      $("#sleep_amount").val(ui.value)
  })

  $("#stress_scale").slider({
    min: 0,
    max: 3,
    value: 1
  }).slider({
    slide: (event, ui) ->
        $("#stress_percent").html(stressList[ui.value])
    change: (event, ui) ->
      $("#stress_amount").val(ui.value)
  })

  $("#illness_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
  slide: (event, ui) ->
    $("#illness_percent").html(illnessList[ui.value])
  change: (event, ui) ->
    $("#illness_amount").val(ui.value)
  })

  $("#pain_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
    slide: (event, ui) ->
      $("#pain_percent").html(painList[ui.value])
    change: (event, ui) ->
      $("#pain_amount").val(ui.value)
  })

  $("#periods_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
  slide: (event, ui) ->
    $("#periods_percent").html(periodPainList[ui.value])
  change: (event, ui) ->
    $("#periods_amount").val(ui.value)
  })

  $("#periods_volume_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
  slide: (event, ui) ->
    $("#periods_volume_percent").html(periodVolumeList[ui.value])
  change: (event, ui) ->
    $("#periods_volume_amount").val(ui.value)
  })

  $("form.resource-create-form.lifestyle-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    load_lifestyles()
    $('#illness_name').val(null)
    $('#illnessname').val(null)
    $('#pain_name').val(null)
  ).on("ajax:error", (e, xhr, status, error) ->
    alert("Failed to create object.")
    $('#illness_name').val(null)
    $('#illnessname').val(null)
    $('#pain_name').val(null)
    console.log xhr.responseText
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
    if(data.group=="sleep")
      $("#sleep_amount").val(data.amount)
      $("#sleep_percent").html(sleepList[data.amount])
      $("#sleep_scale").slider({value: data.amount})
    else if(data.group=="stress")
      $("#stress_amount").val(data.amount)
      $("#stress_percent").html(stressList[data.amount])
      $("#stress_scale").slider({value: data.amount})
    else if(data.group=="illness")
      $("#illness_name").val(data.illness_illname)
      $("#illnessname").val(data.illness_type_id)
      $("#illness_amount").val(data.amount)
      $("#illness_percent").html(illnessList[data.amount])
      $("#illness_scale").slider({value: data.amount})
    else if(data.group=="pain")
      $("#pain_name").val(data.pain_type_name)
      $("#pain_amount").val(data.amount)
      $("#pain_percent").html(painList[data.amount])
      $("#pain_scale").slider({value: data.amount})
    else if(data.group=="period")
      $("#periods_amount").val(data.amount)
      $("#periods_percent").html(periodPainList[data.amount])
      $("#periods_scale").slider({value: data.amount})
      $("#periods_volume_amount").val(data.period_volume)
      $("#periods_volume_percent").html(periodVolumeList[data.period_volume])
      $("#periods_volume_scale").slider({value: data.period_volume})
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

@load_illness_types = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load illness types"
  $.ajax '/illness_types.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load illness_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load illness_types  Successful AJAX call"

      illnesses = data.map( window.illness_map_fn )

      $("#illness_name").autocomplete({
        minLength: 3,
        source: (request, response) ->
          matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
          result = []
          cnt = 0
          for element in illnesses
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
          response(result)
        select: (event, ui) ->
          $("#illnessname").val(ui.item.id)
        create: (event, ui) ->
          document.body.style.cursor = 'auto'
          $("#illness_name").removeAttr("disabled")
      })
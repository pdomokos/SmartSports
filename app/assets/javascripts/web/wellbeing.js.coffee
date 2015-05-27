@wellbeing_loaded = () ->
  uid = $("#current-user-id")[0].value
  popup_messages = JSON.parse($("#popup-messages").val())

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#wellbeing-link").addClass("selected")

  $('#sleep_start_datepicker').datetimepicker(timepicker_defaults)
  $('#sleep_end_datepicker').datetimepicker(timepicker_defaults)
  $('#pain_start_datepicker').datetimepicker(timepicker_defaults)
  $('#pain_end_datepicker').datetimepicker(timepicker_defaults)

  sleepList = $("#sleepList").val().split(",")
  stressList = $("#stressList").val().split(",")
  illnessList = $("#illnessList").val().split(",")
  painList = $("#painList").val().split(",")
  periodPainList = $("#periodPainList").val().split(",")
  periodVolumeList = $("#periodVolumeList").val().split(",")
  painTypeList = $("#painTypeList").val().split(",")

  load_illness_types()
  load_lifestyles()

  painSelected = null
  $("#pain_name").autocomplete({
    minLength: 0,
    source: painTypeList,
    change: (event, ui) ->
      painSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

  $("#pain-create-form button").click ->
    if(!painSelected)
      val = $("#pain_name").val()
      if !val
        val = "empty item"
      console.log("painsel "+val)
      popup_error(popup_messages.failed_to_add_data)
      painSelected = null
      return false
    painSelected = null
    return true

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

  $('#periods_start_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('#periods_end_datepicker').datetimepicker({
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
  $("#sleep_amount").val(2)

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
  $("#stress_amount").val(1)

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
  $("#illness_amount").val(1)

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
  $("#pain_amount").val(1)

  $("#periods_amount").val(1)
  $("#periods_volume_amount").val(1)
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
  $("#periods_amount").val(1)

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
  $("#periods_volume_amount").val(1)

  $("form.resource-create-form.lifestyle-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    load_lifestyles()
    $('#illness_name').val(null)
    $('#illnessname').val(null)
    $('#pain_name').val(null)
    console.log data
    msg = capitalize(data['group'])
    if data['group']=='illness'
      msg = data['illness_name']
    else
      if data['group'] =='pain'
        msg = data['pain_name']
    popup_success(popup_messages.save_success)
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

@load_lifestyles = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent lifestyles"
  lang = $("#data-lang-wellbeing")[0].value
  $.ajax '/users/' + current_user + '/lifestyles.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent lifestyles AJAX Error: #{textStatus}"
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

      illnessSelected = null
      popup_messages = JSON.parse($("#popup-messages").val())
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
        change: (event, ui) ->
          illnessSelected = ui['item']
      })
      $("#illness-create-form button").click ->
        if(!illnessSelected)
          val = $("#illness_name").val()
          if !val
            val = "empty item"
          popup_error(popup_messages.failed_to_add_data)
          illnessSelected = null
          return false
        illnessSelected = null
        return true
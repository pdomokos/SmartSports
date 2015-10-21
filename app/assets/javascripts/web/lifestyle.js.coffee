@wellbeing_loaded = () ->
  uid = $("#current-user-id")[0].value
  @popup_messages = JSON.parse($("#popup-messages").val())

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#wellbeing-link").css
    background: "rgba(232, 115, 180, 0.3)"

  initLifestyle()
  loadLifestyles()

  $("form.resource-create-form.lifestyle-form").on("ajax:success", (e, data, status, xhr) ->
    self = this
    form_id = e.currentTarget.id
    loadLifestyles()
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

    resetLifesyleForms()
    popup_success(popup_messages.save_success, $("#addWellbeingButton").css("background"))
  ).on("ajax:error", (e, xhr, status, error) ->
    alert("Failed to create object.")
    $('#illness_name').val(null)
    $('#illnessname').val(null)
    $('#pain_name').val(null)
    console.log xhr.responseText
  )

  $("form.resource-create-form.lifestyle-form button").on('click', (evt) ->
    return validateLifestyleForm(evt.target.parentNode.parentNode.querySelector("form").id)
  )

  $("#recentResourcesTable").on("click", "td.lifestyleItem", (e) ->
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    fn = window["load_lifestyle_"+data.lifestyle.group];
    if typeof fn == 'function'
      fn('#lifestyle_forms .lifestyle_'+data.lifestyle.group+"-create-form", data)
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    loadLifestyles()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

  $('.hisTitle').click ->
    loadLifestyles()

@initLifestyle = () ->
  self = this

  @sleepList = $("#sleepList").val().split(",")
  @stressList = $("#stressList").val().split(",")
  @illnessList = $("#illnessList").val().split(",")
  @painList = $("#painList").val().split(",")
  @periodPainList = $("#periodPainList").val().split(",")
  @periodVolumeList = $("#periodVolumeList").val().split(",")
  @painTypeList = $("#painTypeList").val().split(",")

  console.log("running initLifestyle")
  $('.sleep_start_datepicker').datetimepicker(timepicker_defaults)
  $('.sleep_end_datepicker').datetimepicker(timepicker_defaults)
  $(".sleep_scale").slider({
    min: 0,
    max: 3,
    value: 2
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".sleep_percent").innerHTML = sleepList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".sleep_amount").value = ui.value
  })
  $(".sleep_amount").val(2)

  $(".stress_scale").slider({
    min: 0,
    max: 3,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".stress_percent").innerHTML = stressList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".stress_amount").value = ui.value
  })
  $(".stress_amount").val(1)

  $('.stress_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $(".illness_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
  slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".illness_percent").innerHTML = illnessList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".illness_amount").value = ui.value
  })
  $(".illness_amount").val(1)

  $('.illness_start_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('.illness_end_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('.pain_start_datepicker').datetimepicker(timepicker_defaults)
  $('.pain_end_datepicker').datetimepicker(timepicker_defaults)
  $("input[name='lifestyle[pain_type_name]']").autocomplete({
    minLength: 0,
    source: painTypeList,
    change: (event, ui) ->
      console.log ui
      $("input[name='lifestyle[pain_type_name]']").val(ui['item'].value)
  }).focus ->
    $(this).autocomplete("search")

  $(".pain_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".pain_percent").innerHTML = painList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".pain_amount").value = ui.value
  })
  $(".pain_amount").val(1)


  $('.period_start_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('.period_end_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $(".period_amount").val(1)
  $(".period_volume_amount").val(1)
  $(".period_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".period_percent").innerHTML = periodPainList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".period_amount").value = ui.value
  })
  $(".period_amount").val(1)

  $(".period_volume_scale").slider({
    min: 0,
    max: 4,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".period_volume_percent").innerHTML = periodVolumeList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".period_volume_amount").value = ui.value
  })
  $(".period_volume_amount").val(1)
  loadIllnessTypes()

@resetLifesyleForms = () ->
  $(".sleep_scale").slider({value: 2})
  $(".sleep_percent").html(sleepList[2])
  $(".stress_scale").slider({value: 1})
  $(".stress_percent").html(stressList[1])
  $(".illness_scale").slider({value: 1})
  $(".illness_percent").html(illnessList[1])
  $(".pain_scale").slider({value: 1})
  $(".pain_percent").html(illnessList[1])
  $(".default_datetime_picker").val(new moment().format(moment_fmt))
  $(".default_date_picker").val(new moment().format(moment_datefmt))
  $("input[name='illness_name']").val("")
  $("input[name='lifestyle[illness_type_id]']").val("")
  $("input[name='lifestyle[pain_type_name]']").val("")

@validateLifestyleForm = (formId) ->
  console.log "validate lifestyle: "+formId
  formNode = document.getElementById(formId)
  group = formNode.querySelector("input[name='lifestyle[group]']").value
  console.log "group = "+group
  if group=='illness' && isempty("#"+formId+" input[name='illness_name']")
    popup_error(popup_messages.illness_name_missing, $("#addMeasurementButton").css("background"))
    return false
  if group=='pain' && isempty("#"+formId+" input[name='lifestyle[pain_type_name]']")
    popup_error(popup_messages.pain_name_missing, $("#addMeasurementButton").css("background"))
    return false

@loadLifestyles = () ->
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

@loadIllnessTypes = () ->
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
      $("input[name='illness_name']").autocomplete({
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
          event.target.parentElement.parentElement.querySelector("input[name='lifestyle[illness_type_id]']").value = ui.item.id
        create: (event, ui) ->
          document.body.style.cursor = 'auto'
          event.target.parentElement.parentElement.querySelector("input[name='illness_name']").removeAttribute("disabled")
        change: (event, ui) ->
          if ui.item
            event.target.parentElement.parentElement.querySelector("input[name='lifestyle[illness_type_id]']").value = ui.item.id
          else
            event.target.parentElement.parentElement.querySelector("input[name='lifestyle[illness_type_id]']").value = ""
      })

@load_lifestyle_sleep = (sel, data) ->
  console.log "load sleep "+sel
  console.log data
  lifestyle = data['lifestyle']
  $(sel+" .sleep_scale").slider({value: lifestyle.amount})
  $(sel+" .sleep_percent").html(sleepList[lifestyle.amount])
  $(sel+" input[name='lifestyle[start_time]']").val(fixdate(lifestyle.start_time))
  $(sel+" input[name='lifestyle[end_time]']").val(fixdate(lifestyle.end_time))

@load_lifestyle_stress = (sel, data) ->
  console.log "load stress"+sel+", ignored"
# doesn't make sense to load this from history
#  console.log data
#  lifestyle = data['lifestyle']
#  $(sel+" .stress_scale").slider({value: lifestyle.amount})
#  $(sel+" .stress_percent").html(stressList[lifestyle.amount])
#  $(sel+" input[name='lifestyle[start_time]']").val(fixdate(lifestyle.start_time))

@load_lifestyle_illness = (sel, data) ->
  console.log "load illness"+sel
  console.log data
  lifestyle = data['lifestyle']
  $(sel+" .illness_name").val(data.illness_name)
  $(sel+" .illness_type_id").val(lifestyle.illness_type_id)
  $(sel+" .illness_scale").slider({value: lifestyle.amount})
  $(sel+" .illness_percent").html(illnessList[lifestyle.amount])
  $(sel+" input[name='lifestyle[start_time]']").val(new moment().format(moment_datefmt))
  $(sel+" input[name='lifestyle[end_time]']").val(new moment().format(moment_datefmt))

@load_lifestyle_pain = (sel, data) ->
  console.log "load pain"+sel
  console.log data
  lifestyle = data['lifestyle']
  $(sel+" .pain_type_name").val(lifestyle.pain_type_name)
  $(sel+" .pain_scale").slider({value: lifestyle.amount})
  $(sel+" .pain_percent").html(illnessList[lifestyle.amount])
  $(sel+" input[name='lifestyle[start_time]']").val(new moment().format(moment_fmt))
  $(sel+" input[name='lifestyle[end_time]']").val(new moment().format(moment_fmt))


@load_lifestyle_period = (sel, data) ->
  console.log "load period"+sel+", ignored"


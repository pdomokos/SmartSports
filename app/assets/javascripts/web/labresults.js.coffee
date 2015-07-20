@labresults_loaded = () ->

  uid = $("#current-user-id")[0].value

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#labresults-link").css
    background: "rgba(237, 170, 171, 0.3)"

  $('#hba1c_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })
  $('#ldl_chol_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })
  $('#egfr_epi_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })
  $('#ketone_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })
  $('#controll_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })
  $('#next_controll_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  init_labresult()
  load_labresult()

@init_labresult = () ->
  console.log "init labres"


  doctorList = $("#doctorList").val().split(";")
  controlList = [{ label: doctorList[0], value: doctorList[0]},
    { label: doctorList[1], value: doctorList[1]}
  ]

  controlSelected = null
  $("#control").autocomplete({
    minLength: 0,
    source: controlList,
    change: (event, ui) ->
      controlSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

  ketoneList = [ { label: "Negative", value: "Negative" },
    { label: "+", value: "+" },
    { label: "++", value: "++" },
    { label: "+++", value: "+++" },
    { label: "++++", value: "++++" },
    { label: "+++++", value: "+++++" }
  ]

  ketoneSelected = null
  $("#ketone").autocomplete({
    minLength: 0,
    source: ketoneList,
    change: (event, ui) ->
      ketoneSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

  popup_messages = JSON.parse($("#popup-messages").val())
  $("#control-create-form button").click ->
    if(!controlSelected)
      val = $("#control").val()
      if !val
        val = "empty item"
      popup_error(popup_messages.failed_to_add_data, $("#addLabResultButton").css("background"))
      controlSelected = null
      return false
    controlSelected = null
    return true

  $("#ketone-create-form button").click ->
    if(!ketoneSelected)
      val = $("#ketone").val()
      if !val
        val = "empty item"
      popup_error(popup_messages.failed_to_add_data, $("#addLabResultButton").css("background"))
      ketoneSelected = null
      return false
    ketoneSelected = null
    return true

  $("#hba1c-create-form button").click ->
    if( isempty("#hba1c") || notpositive("#hba1c"))
      popup_error(popup_messages.failed_to_create_HBA1C, $("#addLabResultButton").css("background"))
      return false
    return true
  $("#ldlchol-create-form button").click ->
    if( isempty("#ldl_chol") || notpositive("#ldl_chol"))
      popup_error(popup_messages.failed_to_create_LDL, $("#addLabResultButton").css("background"))
      return false
    return true
  $("#egfrepi-create-form button").click ->
    if( isempty("#egfr_epi") || notpositive("#egfr_epi"))
      popup_error(popup_messages.failed_to_create_EGFR, $("#addLabResultButton").css("background"))
      return false
    return true

  $("form.resource-create-form.lab_results-form").on("ajax:success", (e, data, status, xhr) ->
    load_labresult()
    console.log data
    $("#control").val(null)
    $("#hba1c").val(null)
    $("#ldl_chol").val(null)
    $("#egfr_epi").val(null)
    $("#ketone").val(null)
    category = data['category']
    if category == 'controll'
      category = 'Kontroll'
    popup_success(capitalize(category)+popup_messages.saved_successfully, $("#addLabResultButton").css("background"))
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_add_data, $("#addLabResultButton").css("background"))
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    load_labresult()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, $("#addLabResultButton").css("background"))
  )


@load_labresult = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent lab_results"
  lang = $("#data-lang-labresult")[0].value
  url = '/users/' + current_user + '/lab_results.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  console.log url
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent lab_results AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent lab_results  Successful AJAX call"
      console.log textStatus

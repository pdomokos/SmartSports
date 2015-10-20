@labresults_loaded = () ->
  console.log "labresults loaded"
  uid = $("#current-user-id")[0].value

  initLabresult()
  loadLabresult()
  loadVisits()

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#labresults-link").css
    background: "rgba(237, 170, 171, 0.3)"

  $("#control-create-form button").click ->
    if(!controlSelected)
      val = $("#control_txt").val()
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

  $("form.resource-create-form.notifications-form").on("ajax:success", (e, data, status, xhr) ->
    console.log "notification created, ret = "
    console.log data
    if data.ok
      load_visits()
      popup_success("Notification "+popup_messages.saved_successfully, $("#addLabResultButton").css("background"))
    else
      popup_error(popup_messages.failed_to_add_data, $("#addLabResultButton").css("background"))
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_add_data, $("#addLabResultButton").css("background"))
  )

  $("form.resource-create-form.lab_results-form").on("ajax:success", (e, data, status, xhr) ->
    category = data['category']
    console.log "labresult form ajax success with data:"
    console.log data
    if category
      loadLabresult()

    $("#control_txt").val(null)
    $("#hba1c").val(null)
    $("#ldl_chol").val(null)
    $("#egfr_epi").val(null)
    $("#ketone").val(null)

    if !category
      category = 'control'
    popup_success(capitalize(category)+popup_messages.saved_successfully, $("#addLabResultButton").css("background"))
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_add_data, $("#addLabResultButton").css("background"))
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    loadLabresult()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, $("#addLabResultButton").css("background"))
  )

  $("#recentVisitsTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    load_visits()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, $("#addLabResultButton").css("background"))
  )

@initLabresult = () ->
  console.log "init labres"

  doctorList = $("#doctorList").val().split(";")
  controlList = [{ label: doctorList[0], value: doctorList[0], intValue: 1},
    { label: doctorList[1], value: doctorList[1], intValue: 2}
  ]

  controlSelected = null
  $("#control_txt").autocomplete({
    minLength: 0,
    source: controlList,
    change: (event, ui) ->
      console.log ui.item
      controlSelected = ui.item
      $("#control").val(ui.item.intValue)
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
    timepicker: false,
    todayButton: true
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
  })
  $('#next_controll_datepicker').datetimepicker({
    format: 'Y-m-d H:i',
    timepicker: true,
    todayButton: true,
    onSelectTime: (ct, input) ->
      input.datetimepicker('hide')
  })

  @popup_messages = JSON.parse($("#popup-messages").val())

@loadLabresult = () ->
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

@loadVisits = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent lab_results"
  lang = $("#data-lang-labresult")[0].value
  url = '/users/' + current_user + '/notifications.js?upcoming=true&order=asc&limit=10&lang='+lang
  console.log url
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent lab_results AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent lab_results  Successful AJAX call"
      console.log textStatus

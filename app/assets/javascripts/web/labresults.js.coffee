@labresults_loaded = () ->

  uid = $("#current-user-id")[0].value

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#labresults-link").addClass("selected")

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

  init_labresult()
  load_labresult()

@init_labresult = () ->
  console.log "init labres"

  $('#hba1c').focus()

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

  $("#ketone-create-form button").click ->
    if(!ketoneSelected)
      val = $("#ketone").val()
      if !val
        val = "empty item"
      popup_error("Failed to add "+val)
      ketoneSelected = null
      return false
    ketoneSelected = null
    return true

  $("#hba1c-create-form button").click ->
    if( isempty("#hba1c") || notpositive("#hba1c"))
      popup_error("Failed to create HBA1C")
      return false
    return true
  $("#ldlchol-create-form button").click ->
    if( isempty("#ldl_chol") || notpositive("#ldl_chol"))
      popup_error("Failed to create LDL-CHOL")
      return false
    return true
  $("#egfrepi-create-form button").click ->
    if( isempty("#egfr_epi") || notpositive("#egfr_epi"))
      popup_error("Failed to create EGFR-EPI")
      return false
    return true

  $("form.resource-create-form.lab_results-form").on("ajax:success", (e, data, status, xhr) ->
    load_labresult()
    console.log data
    $("#hba1c").val(null)
    $("#ldl_chol").val(null)
    $("#egfr_epi").val(null)
    $("#ketone").val(null)
    popup_success(capitalize(data['category'])+" saved successfully")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error("Failed to create labresult")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    load_labresult()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error("Failed to delete labresult")
  )


@load_labresult = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent lab_results"
  url = '/users/' + current_user + '/lab_results.js?source='+window.default_source+'&order=desc&limit=10'
  console.log url
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent lab_results AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent lab_results  Successful AJAX call"
      console.log textStatus

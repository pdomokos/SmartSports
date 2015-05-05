@labresults_loaded = () ->

  uid = $("#current-user-id")[0].value

  $("div.appMenu button").removeClass("selected")
  $("#labresults-button").addClass("selected")

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

  $("#ketone").autocomplete({
    minLength: 0,
    source: ketoneList
  }).focus ->
    $(this).autocomplete("search")

  $("form.resource-create-form.lab_results-form").on("ajax:success", (e, data, status, xhr) ->
    load_labresult()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create labresult.")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    load_labresult()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete labresult.")
  )

  $("#recentResourcesTable").on("click", "td.labresultItem", (e) ->
    console.log "loading labresult"
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    console.log data
    if(data.category=="hba1c")
      $("#hba1c").val(data.hba1c)
    else if(data.category=="ldl_chol")
      $("#ldl_chol").val(data.ldl_chol)
    else if(data.category=="egfr_epi")
      $("#egfr_epi").val(data.egfr_epi)
    else if(data.category=="ketone")
      $("#ketone").val(data.ketone)
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

@labresults_loaded = () ->

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

  init_labresult()
  load_labresult()

@init_labresult = () ->
  console.log "init labres"

  $('#hba1c').focus()

#  popup_messages = JSON.parse($("#popup-messages").val())
#  $("#ketone-create-form button").click ->
#    if(!ketoneSelected)
#      val = $("#ketone").val()
#      if !val
#        val = "empty item"
#      popup_error(popup_messages.failed_to_add_data, $("#addLabResultButton").css("background"))
#      ketoneSelected = null
#      return false
#    ketoneSelected = null
#    return true
#
#  $("#hba1c-create-form button").click ->
#    if( isempty("#hba1c") || notpositive("#hba1c"))
#      popup_error(popup_messages.failed_to_create_HBA1C, $("#addLabResultButton").css("background"))
#      return false
#    return true
#  $("#ldlchol-create-form button").click ->
#    if( isempty("#ldl_chol") || notpositive("#ldl_chol"))
#      popup_error(popup_messages.failed_to_create_LDL, $("#addLabResultButton").css("background"))
#      return false
#    return true
#  $("#egfrepi-create-form button").click ->
#    if( isempty("#egfr_epi") || notpositive("#egfr_epi"))
#      popup_error(popup_messages.failed_to_create_EGFR, $("#addLabResultButton").css("background"))
#      return false
#    return true

  $(document).on("ajax:success", "form.resource-create-form.labresult-form", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    $("#"+form_id+" input.dataFormField").val("")

    $("#hba1c").val(null)
    $("#ldl_chol").val(null)
    $("#egfr_epi").val(null)
    $("#ketone").val("negative").selectmenu("refresh",true)

    load_labresult()
    $("#successLabresultPopup").popup("open")

  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    $('#medname').val(null)
    $('#insname').val(null)
    $("#failureLabresultPopup").popup("open")
  )

  $(document).on("ajax:success", "#deleteLabresult", (e, data, status, xhr) ->
    console.log("delete successfull")
    $("#labresultPage").attr("data-scrolltotable", true)
    $.mobile.navigate( "#labresultPage" )
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete labresult.")
  )

  $(document).on("pagecontainershow", (event, ui) ->
    console.log("labresult pagecontainershow")
    load_labresult()
  )

@load_labresult = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent labresults"
  lang = $("#data-lang-labresult")[0].value
  url = '/users/' + current_user + '/lab_results.js?source='+window.default_source+'&order=desc&limit=10&mobile=true'
  if lang
    url = url+"&lang="+lang
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent lab_results AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent lab_results  Successful AJAX call"
      console.log textStatus
      if $("#labresultPage").attr('data-scrolltotable')
        $.mobile.silentScroll($("div.ui-navbar").offset().top)
        $("#labresultPage").attr('data-scrolltotable', null)
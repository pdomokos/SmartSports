@medications_loaded = () ->
  console.log("medications loaded")

  $("div.appMenu button").removeClass("selected")
  $("#medication-button").addClass("selected")

  $('#medication_dosage').watermark('Unit Dosage, eg: 2')
  $('#medication_amount').watermark('Amount Taken, eg: 1')

  $('#medication_insulin_dosage').watermark('Dosage, eg: 2')


  $('#medications_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })

  $('#medications_insulin_datepicker').datetimepicker({
    "format": "YYYY-MM-DD HH:mm"
  })


  $("#oral_medication_name").scombobox()
  $('#oral_medication_name input').watermark('Medication Name, eg: Amaryl')

  $("#insulin_name").scombobox()
  $('#insulin_name input').watermark('Insulin Type, eg: Exubera')

  $("form.resource-create-form.medication-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log e
    console.log xhr.responseText
    $("#"+form_id+" input.dataFormField").val("")
    $("#"+form_id+" div.scombobox").scombobox("val", "")

    load_medications()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create diet.")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    load_medications()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

  @load_medications = () ->
    self = this
    current_user = $("#current-user-id")[0].value
    console.log "calling load recent medications"
    $.ajax '/users/' + current_user + '/medications.js?source='+window.default_source+'&order=desc&limit=4',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load recent medications AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "load recent medications  Successful AJAX call"
        console.log textStatus


@medications_loaded = () ->
  console.log("medications loaded")
  $("div.app2Menu a.menulink").removeClass("selected")
  $("#medication-link").addClass("selected")

  $('#medications_datepicker').datetimepicker(timepicker_defaults)
  $('#medications_insulin_datepicker').datetimepicker(timepicker_defaults)
  popup_messages = JSON.parse($("#popup-messages").val())

  document.body.style.cursor = 'wait'
  load_medication_types()
  loadMedicationHistory()

  $("form.resource-create-form.medication-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    $("#"+form_id+" input.dataFormField").val("")

    $('#medname').val(null)
    $('#insname').val(null)
    $('#medications_datepicker').val(moment().format(moment_fmt))
    $('#medications_insulin_datepicker').val(moment().format(moment_fmt))

    loadMedicationHistory()
    popup_success(data['medication_name']+popup_messages.saved_successfully)
  ).on("ajax:error", (e, xhr, status, error) ->
    $('#medname').val(null)
    $('#insname').val(null)
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_add_data)
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item
    loadMedicationHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data)
  )

  $('.hisTitle').click ->
    loadMedicationHistory()

  $(".favTitle").click ->
    load_medications(true)
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")


@loadMedicationHistory = () ->
  load_medications()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@load_medications = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent medications"
  lang = $("#data-lang-medication")[0].value
  url = '/users/' + current_user + '/medications.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent medications AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      if fav
        $(".deleteMedication").addClass("hidden")
      else
        $(".deleteMedication").removeClass("hidden")
      console.log "load recent medications  Successful AJAX call"
      console.log textStatus


@load_medication_types = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load medication types"
  $.ajax '/medication_types.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent medication_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load medication_types  Successful AJAX call"
      popup_messages = JSON.parse($("#popup-messages").val())
      pills = data.filter( (d) ->
        d['group'] == 'oral'
      ).map( (d) ->
        {
          label: d['name'],
          id: d['id']
      })
      insulin = data.filter( (d) ->
        d['group'] == 'insulin'
      ).map( (d) ->
        {
        label: d['name'],
        id: d['id']
        })
      oralMedSelected = null
      $("#oral_medication_name").autocomplete({
        minLength: 3,
        source: (request, response) ->
          matcher = new RegExp("^" + $.ui.autocomplete.escapeRegex(request.term, ""), "i")
          result = []
          cnt = 0
          for element in pills
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
          response(result)
        select: (event, ui) ->
          $("#medname").val(ui.item.id)
        create: (event, ui) ->
          console.log "med create called"
          $("#oral_medication_name").removeAttr("disabled")
          document.body.style.cursor = 'auto'
        change: (event, ui) ->
          console.log "med change"
          console.log ui['item']
          oralMedSelected = ui['item']
      })
      $("#oral-med-create-form button").click ->
        if(!oralMedSelected)
          val = $("#oral_medication_name").val()
          if !val
            val = "empty item"
          popup_error(popup_messages.failed_to_add_data)
          oralMedSelected = null
          return false
        if( isempty("#medication_amount") || notpositive("#medication_amount"))
          popup_error(popup_messages.invalid_med_amount)
          return false
        oralMedSelected = null
        return true

      insulinSelected = null
      $("#insulin_name").autocomplete({
        minLength: 0,
        source: (request, response) ->
          matcher = new RegExp("^" + $.ui.autocomplete.escapeRegex(request.term, ""), "i")
          result = []
          cnt = 0
          for element in insulin
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
          response(result)
        select: (event, ui) ->
          console.log ui
          $("#insname").val(ui.item.id)
        create: (event, ui) ->
          console.log "insulin create called"
          $("#insulin_name").removeAttr("disabled")
        change: (event, ui) ->
          insulinSelected = ui['item']
      }).focus ->
        console.log "insulin focus called"
        $(this).autocomplete("search")

      $("#insulin-create-form button").click ->
        if(!insulinSelected)
          val = $("#insulin_name").val()
          if !val
            val = "empty item"
          popup_error(popup_messages.failed_to_add_data)
          insulinSelected = null
          return false
        if ( isempty("#medication_insulin_dosage") || notpositive("#medication_insulin_dosage"))
          popup_error(popup_messages.invalid_dosage)
          return false
        insulinSelected = null
        return true

      fn_load_med = (e) ->
        console.log "loading medication"
        data = JSON.parse(e.currentTarget.querySelector("input").value)
        console.log data
        if data.medication_type=="oral"
          $("#oral_medication_name").val(data.medication_name)
          oralMedSelected = data.medication_name
          $("#medname").val(data.medication_type_id)
          $("#medication_amount").val(data.amount)
        else if data.medication_type=="insulin"
          $("#insulin_name").val(data.medication_name)
          insulinSelected = data.medication_name
          $("#insname").val(data.medication_type_id)
          $("#medication_insulin_dosage").val(data.amount)
      $("#recentResourcesTable").on("click", "td.medicationItem", fn_load_med)
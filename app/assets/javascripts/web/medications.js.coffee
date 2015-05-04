@medications_loaded = () ->
  console.log("medications loaded")
  $("div.appMenu button").removeClass("selected")
  $("#medication-button").addClass("selected")

  $('#medications_datepicker').datetimepicker(timepicker_defaults)
  $('#medications_insulin_datepicker').datetimepicker(timepicker_defaults)

  load_medication_types()
  loadMedicationHistory()

  $("form.resource-create-form.medication-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log e
    console.log xhr.responseText
    $("#"+form_id+" input.dataFormField").val("")

    $('#medications_datepicker').val(moment().format(moment_fmt))
    $('#medications_insulin_datepicker').val(moment().format(moment_fmt))

    loadMedicationHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create diet.")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    loadMedicationHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

  $('.hisTitle').click ->
    loadMedicationHistory()

  $(".favTitle").click ->
    load_medications(true)
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

  $("#recentResourcesTable").on("click", "td.medicationItem", (e) ->
    console.log "loading medication"
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    console.log data
    if data.medication_type=="oral"
      $("#oral_medication_name").val(data.medication_name)
      $("#medname").val(data.medication_type_id)
      $("#medication_amount").val(data.amount)
    else if data.medication_type=="insulin"
      $("#insulin_name").val(data.medication_name)
      $("#insname").val(data.medication_type_id)
      $("#medication_insulin_dosage").val(data.amount)
  )

@loadMedicationHistory = () ->
  load_medications()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@load_medications = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent medications"
  url = '/users/' + current_user + '/medications.js?source='+window.default_source+'&order=desc&limit=10'
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent medications AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent medications  Successful AJAX call"
      console.log textStatus


@load_medication_types = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent medications"
  $.ajax '/medication_types.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent medication_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load medication_types  Successful AJAX call"

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
      $("#oral_medication_name").autocomplete({
        minLength: 3,
        source: (request, response) ->
          matcher = new RegExp("^"+$.ui.autocomplete.escapeRegex(request.term, ""), "i")
          result = []
          cnt = 0
          for element in pills
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
            #if cnt >= 100
            #  break
          response(result)
        select: (event, ui) ->
          $("#medname").val(ui.item.id)
      }).focus ->
        $(this).autocomplete("search")
      $("#insulin_name").autocomplete({
        minLength: 0,
        source: (request, response) ->
          matcher = new RegExp("^"+$.ui.autocomplete.escapeRegex(request.term, ""), "i")
          result = []
          cnt = 0
          for element in insulin
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
            #if cnt >= 100
            #  break
          response(result)
        select: (event, ui) ->
          console.log ui
          $("#insname").val(ui.item.id)
      }).focus ->
        $(this).autocomplete("search")
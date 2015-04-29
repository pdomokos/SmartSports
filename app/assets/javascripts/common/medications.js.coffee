@medications_loaded = () ->
  console.log("medications loaded")

  $("div.appMenu button").removeClass("selected")
  $("#medication-button").addClass("selected")

  $('#medication_insulin_dosage').watermark('Unit Dosage, eg: 2')
  $('#medication_amount').watermark('Amount Taken, eg: 1')

  $('#medications_datepicker').datetimepicker(timepicker_defaults)
  $('#medications_insulin_datepicker').datetimepicker(timepicker_defaults)

  $("#oral_medication_name").watermark('Start typing medication, eg: Kal')

  load_medication_types()
#  .autocomplete("instance")._renderItem = (ul, item) ->
#    return $( "<li></li>" )
#      .data( "item.autocomplete", item )
#      .append( "<a>" + "<img src='" + item.imgsrc + "' />" + item.id+ " - " + item.label+ "</a>" )
#      .appendTo( ul );

  ins = ["Exubera1", "Exubera2", "Exubera3"]
  $("#insulin_name").watermark('Start typing insulin, eg: Exu')
  $("#insulin_name").autocomplete({
    source: ins
  })
  $('#insulin_name input').watermark('Insulin Type, eg: Exubera')

  $("form.resource-create-form.medication-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log e
    console.log xhr.responseText
    $("#"+form_id+" input.dataFormField").val("")

    $('#medications_datepicker').val(moment().format(moment_fmt))
    $('#medications_insulin_datepicker').val(moment().format(moment_fmt))

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
        source: (request, response) ->
          matcher = new RegExp("^"+$.ui.autocomplete.escapeRegex(request.term, ""), "i")
          result = []
          cnt = 0
          for element in pills
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
            if cnt >= 20
              break
          response(result)
        select: (event, ui) ->
          $("#medname").val(ui.item.id)
      })
      $("#insulin_name").autocomplete({
        source: (request, response) ->
          matcher = new RegExp("^"+$.ui.autocomplete.escapeRegex(request.term, ""), "i")
          result = []
          cnt = 0
          for element in insulin
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
            if cnt >= 20
              break
          response(result)
        select: (event, ui) ->
          console.log ui
          $("#insname").val(ui.item.id)
      })
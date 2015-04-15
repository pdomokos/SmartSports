@genetics_loaded = () ->
  console.log("genetics loaded")

  $("div.appMenu button").removeClass("selected")
  $("#genetics-button").addClass("selected")

  $('#gen_hist_relative').watermark('Relative, eg: father')
  $('#gen_hist_disease').watermark('Diagnosed disease, eg: diabetes type 1')
  $('#gen_hist_note').watermark('Note, eg: slight obesity')

  $("form.resource-create-form.family-history-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log e
    console.log xhr.responseText
    $("#"+form_id+" input.dataFormField").val("")

    load_family_histories()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to create diet.")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    load_family_histories()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

@load_family_histories = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent family histories"
  $.ajax '/users/' + current_user + '/family_histories.js?source='+window.default_source+'&order=desc&limit=4',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent family hist AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent family hist  Successful AJAX call"
      console.log textStatus

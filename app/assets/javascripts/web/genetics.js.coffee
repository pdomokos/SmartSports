@genetics_loaded = () ->
  console.log("genetics loaded")

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#genetics-link").addClass("selected")

  load_family_histories()

  relativeList = JSON.parse($("#relativeList").val())
  diseaseList = JSON.parse($("#diseaseList").val())

  relativeSelected = null
  $("#gen_hist_relative").autocomplete({
    minLength: 0,
    source: relativeList,
    change: (event, ui) ->
      relativeSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

  diseaseSelected = null
  $("#gen_hist_disease").autocomplete({
    minLength: 0,
    source: diseaseList,
    change: (event, ui) ->
      diseaseSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

  $("#familyhist-create-form button").click ->
    if(relativeSelected==null || diseaseSelected==null)
      popup_error("Failed to add family history, enter valid relative and disease")

      return false
    relativeSelected = null
    diseaseSelected = null
    return true

  $("form.resource-create-form.family-history-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log data
    $("#"+form_id+" input.dataFormField").val("")
    $("#gen_hist_note").val("")
    load_family_histories()
    popup_success(data['disease']+" saved successfully")
  ).on("ajax:error", (e, xhr, status, error) ->
    popup_error("Failed to save family history")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    load_family_histories()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error("Failed to delete family history")
  )

@load_family_histories = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent family histories"
  $.ajax '/users/' + current_user + '/family_histories.js?source='+window.default_source+'&order=desc&limit=10',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent family hist AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent family hist  Successful AJAX call"
      console.log textStatus

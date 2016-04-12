@genetics_loaded = () ->
  console.log("personal_records loaded")

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#genetics-link").css
    background: "rgba(56, 199, 234, 0.3)"

  document.body.style.cursor = 'wait'
  load_genetics_types( () ->
    console.log("geneticstypes loaded")
    document.body.style.cursor = 'auto'
    init_genetics()
    load_genetics()
  )

  popup_messages = JSON.parse($("#popup-messages").val())

  $("form.resource-create-form.genetics_family_history-create-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log data
    $("#"+form_id+" input.dataFormField").val("")
    $("#family_hist_note").val("")
    load_genetics()
    popup_success(popup_messages.saved_successfully, "geneticsStyle")
  ).on("ajax:error", (e, xhr, status, error) ->
    popup_error(popup_messages.failed_to_add_data, "geneticsStyle")
  )

  $("form.resource-create-form.genetics_personal_history-create-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log data
    $("#"+form_id+" input.dataFormField").val("")
    $("#personal_hist_note").val("")
    load_genetics()
    popup_success(popup_messages.saved_successfully, "geneticsStyle")
  ).on("ajax:error", (e, xhr, status, error) ->
    popup_error(popup_messages.failed_to_add_data, "geneticsStyle")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item

    load_genetics()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, "geneticsStyle")
  )

@init_genetics = () ->
  self = this
  relSelected = null
  $(".rel_type_name").autocomplete({
    minLength: 0,
    source: (request, response) ->
      matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
      result = []
      cnt = 0
      user_lang = $("#user-lang")[0].value
      if user_lang
        genkey = 'sd_relatives_'+user_lang
      else
        genkey = 'sd_relatives_hu'
      for element in getStored(genkey)
        if matcher.test(remove_accents(element.label))
          result.push(element)
          cnt += 1
      response(result)
    select: (event, ui) ->
      $(".rel_type_id").val(ui.item.id)
    create: (event, ui) ->
      $(".rel_type_name").removeAttr("disabled")
    change: (event, ui) ->
      relSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

  diabSelected = null
  $(".diab_type_name").autocomplete({
    minLength: 0,
    source: (request, response) ->
      matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
      result = []
      cnt = 0
      user_lang = $("#user-lang")[0].value
      if user_lang
        genkey = 'sd_diabetes_'+user_lang
      else
        genkey = 'sd_diabetes_hu'
      for element in getStored(genkey)
        if matcher.test(remove_accents(element.label))
          result.push(element)
          cnt += 1
      response(result)
    select: (event, ui) ->
      $(".diab_type_id").val(ui.item.id)
    create: (event, ui) ->
      $(".diab_type_name").removeAttr("disabled")
    change: (event, ui) ->
      diabSelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

  antibodySelected = null
  $(".antibody_type_name").autocomplete({
    minLength: 0,
    source: (request, response) ->
      matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
      result = []
      cnt = 0
      user_lang = $("#user-lang")[0].value
      if user_lang
        genkey = 'sd_autoantibody_'+user_lang
      else
        genkey = 'sd_autoantibody_hu'
      for element in getStored(genkey)
        if matcher.test(remove_accents(element.label))
          result.push(element)
          cnt += 1
      response(result)
    select: (event, ui) ->
      $(".antibody_type_id").val(ui.item.id)
    create: (event, ui) ->
      $(".antibody_type_name").removeAttr("disabled")
    change: (event, ui) ->
      antibodySelected = ui['item']
  }).focus ->
    $(this).autocomplete("search")

@load_genetics_types = (cb) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load genetic_record types"
  user_lang = $("#user-lang")[0].value
  db_version = $("#db-version")[0].value
  if user_lang
    geneticskey = 'sd_diabetes_'+user_lang
  else
    geneticskey = 'sd_diabetes_hu'
  if getStored(geneticskey)==undefined || getStored(geneticskey).length==0 || testDbVer(db_version,['sd_diabetes_hu','sd_autoantibody_hu','sd_relatives_hu','sd_diabetes_en','sd_autoantibody_en','sd_relatives_en'])
    ret = $.ajax '/genetics_record_types.json',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load personal_record_types AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "load personal_record_types  Successful AJAX call"

        setStored('sd_diabetes_hu', data.filter( (d) ->
          d['category'] == "diabetes"
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))


        setStored('sd_autoantibody_hu', data.filter( (d) ->
          d['category'] == "autoantibody"
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))


        setStored('sd_diabetes_en', data.filter( (d) ->
          d['category'] == "diabetes"
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))


        setStored('sd_autoantibody_en', data.filter( (d) ->
          d['category'] == "autoantibody"
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))

        setStored('sd_relatives_hu', data.filter( (d) ->
          d['category'] == "relatives"
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))

        setStored('sd_relatives_en', data.filter( (d) ->
          d['category'] == "relatives"
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))


        setStored('db_version', db_version)
        cb()
  else
    ret = new Promise( (resolve, reject) ->
      console.log "personal_records already downloaded"
      cb()
      resolve("personal_records cbs called")
    )
  return ret

@load_genetics = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  lang = $("#user-lang")[0].value
  console.log "calling load recent personal_records"
  url = 'users/' + current_user + '/genetics.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent personal_records hist AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent personal_records hist  Successful AJAX call"
      console.log textStatus

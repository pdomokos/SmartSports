@medications_loaded = () ->
  console.log("medications loaded")
  $("div.app2Menu a.menulink").removeClass("selected")
  $("#medication-link").css
    background: "rgba(112, 197, 203, 0.3)"

  @popup_messages = JSON.parse($("#popup-messages").val())

  document.body.style.cursor = 'wait'
  loadMedicationTypes( () ->
    initMedication()
    loadMedicationHistory()
    document.body.style.cursor = 'auto'
  )

  $("form.resource-create-form.medication-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    $("#"+form_id+" input.dataFormField").val("")

    loadMedicationHistory()
    resetMedications()
  ).on("ajax:error", (e, xhr, status, error) ->
    $('#medname').val(null)
    $('#insname').val(null)
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_add_data, "medicationStyle")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item
    loadMedicationHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, "medicationStyle")
  )

  $("#recentResourcesTable").on("click", "td.medicationItem", (e) ->
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    if(data.medication_type=="insulin" || data.medication_type=="custom_insulin")
      load_medication_insulin("#insulin_form", data)
    if(data.medication_type=="oral" || data.medication_type=="custom_drug")
      load_medication_drugs("#drugs_form", data)
  )

  $("#drugs_form button").click ->
    validate_medication_drugs("#drugs_form")

  $("#insulin_form button").click ->
    validate_medication_insulin("#insulin_form")

  $('.hisTitle').click ->
    loadMedicationHistory()

  $(".favTitle").click ->
    load_medications(true)
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

  $(document).unbind("click.medicationShow")
  $(document).on("click.medicationShow", "#medication-show-table", (evt) ->
    current_user = $("#current-user-id")[0].value
    lang = $("#data-lang-medication")[0].value
    medication_header = $("#medication_header_values").val().split(",")
    url = 'users/' + current_user + '/medications.json'+'?table=true&lang='+lang
    show_table(url, lang, medication_header, 'get_medication_table_row', 'show_medication_table')
  )

  $(document).unbind("click.downloadDiet")
  $(document).on("click.downloadMedication", "#download-medication-data", (evt) ->
    current_user = $("#current-user-id")[0].value
    lang = $("#user-lang")[0].value
    url = '/users/' + current_user + '/medications.csv?order=desc&lang='+lang
    location.href = url
  )

  $(document).unbind("click.closeMedication")
  $(document).on("click.closeMedication", "#close-medication-data", (evt) ->
    $("#medication-data-container").html("")
    location.href = "#close"
  )

@initMedication = (selector) ->
  console.log "initMedication, sel= "+selector
  self = this
  if selector==null||selector==undefined
    selector = " "
  else
    selector = selector+" "

  $(selector+"input[name='medication[date]']").datetimepicker(timepicker_defaults)

  current_user = $("#current-user-id")[0].value
  custom_medications = null
  url = 'users/' + current_user + '/custom_medication_types.json'
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load custom medications AJAX Error: "+errorThrown
    success: (data, textStatus, jqXHR) ->
      console.log "load custom medications  Successful AJAX call"
      custom_medications = data
      $(selector+".oral_medication_sel").autocomplete({
        minLength: 3,
        source: (request, response) ->
          matcher = new RegExp("^" + $.ui.autocomplete.escapeRegex(request.term, ""), "i")
          result = []
          cnt = 0
          user_lang = $("#user-lang")[0].value
          if user_lang
            pillkey = 'sd_pills_'+user_lang
          else
            pillkey = 'sd_pills_hu'
          store = getStored(pillkey)
          custom_drugs = []
          for customelement in custom_medications
            if customelement['category'] == 'custom_drug'
              custom_drugs.push(customelement)
          store = store.concat(custom_drugs)
          for element in store
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
          response(result)
        select: (event, ui) ->
            $(selector+".oral_medication_name").val(ui.item.id)
        create: (event, ui) ->
          $(selector+".oral_medication_sel").removeAttr("disabled")
        change: (event, ui) ->
          console.log ui['item']
          if ui['item'] == null || (ui['item'].category && ui['item'].category.startsWith("custom"))
            $(selector+".oral_medication_name").val(null)
            $(selector+".oral_medication_custom_name").val($(selector+".oral_medication_sel").val())
      })

      $(selector+".insulin_medication_sel").autocomplete({
        minLength: 0,
        source: (request, response) ->
          matcher = new RegExp("^" + $.ui.autocomplete.escapeRegex(request.term, ""), "i")
          result = []
          cnt = 0
          user_lang = $("#user-lang")[0].value
          if user_lang
            insulinkey = 'sd_insulin_'+user_lang
          else
            insulinkey = 'sd_insulin_hu'
          store = getStored(insulinkey)
          custom_insulins = []
          for customelement in custom_medications
            if customelement['category'] == 'custom_insulin'
              custom_insulins.push(customelement)
          store = store.concat(custom_insulins)
          for element in store
            if matcher.test(element.label)
              result.push(element)
              cnt += 1
          response(result)
        select: (event, ui) ->
          console.log ui
          $(selector+".insulin_medication_name").val(ui.item.id)
        create: (event, ui) ->
          $(selector+".insulin_medication_sel").removeAttr("disabled")
        change: (event, ui) ->
          insulinSelected = ui['item']
          if ui['item'] == null || (ui['item'].category && ui['item'].category.startsWith("custom"))
            $(selector+".insulin_medication_name").val(null)
            $(selector+".insulin_medication_custom_name").val($(selector+".insulin_medication_sel").val())
      }).focus ->
        console.log "insulin focus called"
        $(this).autocomplete("search")

@resetMedications = () ->
  $(".custom_oral_medication_name").val("")
  $(".custom_insulin_medication_name").val("")
  $('.medication_drugs_datepicker').val(moment().format(moment_fmt))
  $('.medication_insulin_datepicker').val(moment().format(moment_fmt))

@loadMedicationHistory = () ->
  load_medications()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@load_medications = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent medications"
  lang = $("#data-lang-medication")[0].value
  url = 'users/' + current_user + '/medications.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent medications AJAX Error: "+errorThrown
    success: (data, textStatus, jqXHR) ->
      if fav
        $(".deleteMedication").addClass("hidden")
      else
        $(".deleteMedication").removeClass("hidden")
      console.log "load recent medications  Successful AJAX call"
      console.log textStatus


@loadMedicationTypes = (cb) ->
  self = this
  current_user = $("#current-user-id")[0].value
  db_version = $("#db-version")[0].value

  user_lang = $("#user-lang")[0].value
  if user_lang
    pillkey = 'sd_pills_'+user_lang
  else
    pillkey = 'sd_pills_hu'

  if getStored(pillkey)==undefined || getStored(pillkey).length==0 || testDbVer(db_version,['sd_pills_hu', 'sd_pills_en', 'sd_insulin_hu', 'sd_insulin_en'])
    console.log "calling load medication types"
    ret = $.ajax urlPrefix()+'medication_types.json',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load recent medication_types AJAX Error: "+errorThrown
      success: (data, textStatus, jqXHR) ->
        console.log "load medication_types  Successful AJAX call"
        popup_messages = JSON.parse($("#popup-messages").val())
        setStored("sd_pills_hu", data.filter( (d) ->
          d['category'] == 'oral'
        ).map( (d) ->
          {
            label: d['hu'],
            id: d['name']
        }))
        setStored("sd_pills_en", data.filter( (d) ->
          d['category'] == 'drugs_en'
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))
        setStored("sd_insulin_hu", data.filter( (d) ->
          d['category'] == 'insulin'
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))
        setStored("sd_insulin_en", data.filter( (d) ->
          d['category'] == 'insulin_en'
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))

        setStored('db_version', db_version)
        cb()
  else
    console.log "medication types already loaded"
    ret = new Promise( (resolve, reject) ->
      console.log("medication promise fn called")
      cb()
      resolve("medication cbs called")
    )
    return ret

validate_medication_common = (sel) ->
  console.log sel+" input[name='medication[name]']"
  console.log $(sel+" input[name='medication[name]']").val()
  console.log sel+" input[name='medication[custom_name]']"
  console.log $(sel+" input[name='medication[custom_name]']").val()
  if (!$(sel+" input[name='medication[name]']").val() && !$(sel+" input[name='medication[custom_name]']").val())
    popup_error(popup_messages.failed_to_add_data, "medicationStyle")
    return false
  if( !$(sel+" input[name='medication[amount]']").val() || notpositive(sel+" input[name='medication[amount]']"))
    popup_error(popup_messages.invalid_med_amount, "medicationStyle")
    return false
  return true

@validate_medication_form = (sel) ->
  console.log "validating drugs "+sel
  validate_medication_common(sel)

@validate_medication_drugs = (sel) ->
  console.log "validating drugs "+sel
  validate_medication_common(sel)

@validate_medication_insulin = (sel) ->
  console.log "validating insulin "+sel
  validate_medication_common(sel)

@load_medication_drugs = (sel, data) ->
  console.log "loading medication "+sel
  console.log data
  medication = data['medication']

  if medication.medication_type_id
    $(sel+" input[name='medication[name]']").val(data['medication_name'])
    $(sel+" input[name='medication[medication_name]']").val(get_medication_label(data['medication_name']))
  else if medication.custom_medication_type_id
    $(sel+" input[name='medication[medication_name]']").val(data['medication_name'])
    $(sel+" input[name='medication[custom_name]']").val(data['medication_name'])
  $(sel+" input[name='medication[amount]']").val(medication.amount)
  $(sel+" input[name='medication[date]']").val(moment().format(moment_fmt))

@load_medication_insulin = (sel, data) ->
  console.log "loading insulin"
  medication = data['medication']
  #TODO nem adodik a select listahoz
  if medication.medication_type_id
    $(sel+" input[name='medication[name]']").val(data['medication_name'])
    $(sel+" input[name='medication[medication_name]']").val(get_medication_label(data['medication_name']))
  else if medication.custom_medication_type_id
    $(sel+" input[name='medication[medication_name]']").val(data['medication_name'])
    $(sel+" input[name='medication[custom_name]']").val(data['medication_name'])
  $(sel+" input[name='medication[amount]']").val(medication.amount)
  $(sel+" input[name='medication[date]']").val(moment().format(moment_fmt))

@get_medication_label = (key) ->
  user_lang = $("#user-lang")[0].value
  arr = ['sd_pills_', 'sd_insulin_']
  value = null
  console.log "get_label "+key

  arr.forEach((item) ->
    if user_lang
      med_db = item+user_lang
    else
      med_db = item+'hu'

    if getStored(med_db)!=undefined && getStored(med_db).length!=0
      tmp = getStored(med_db).filter((d) ->
        return d.id==key;
      )
      if tmp.length!=0
        value = tmp[0].label
  )
  if value==null
    value = 'Unknown'
  return value
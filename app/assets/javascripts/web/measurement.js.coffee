@health_loaded = () ->
  uid = $("#current-user-id")[0].value
  @popup_messages = JSON.parse($("#popup-messages").val())

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#health-link").css
    background: "rgba(137, 130, 200, 0.3)"

  document.body.style.cursor = 'wait'
  load_meas_types( () ->
    console.log("measurementtypes loaded")
    document.body.style.cursor = 'auto'
    initMeasurement()
    loadHealthHistory()
  )
  
  $("form.resource-create-form.measurement-form button").on('click', (evt) ->
    return validate_measurement_form("#"+evt.target.parentNode.parentNode.querySelector("form").id)
  )

  $("form.resource-create-form.measurement-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    validateBgInterval(form_id, data["id"])

    $("#"+form_id+" input.dataFormField").val("")
    $('.defaultDatePicker').val(moment().format(moment_fmt))

    loadHealthHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    console.log error
    popup_error(popup_messages.failed_to_add_data, "healthStyle")
  )

  $("#save-bgnote-form").click ->
    current_meas = $("#measIdToNote")[0].value
    current_user = $("#current-user-id")[0].value
    meas_note = $("#measNote")[0].value
    url = 'users/' + current_user + '/measurements/'+ current_meas
    $.ajax urlPrefix()+url,
      type: 'PUT',
      data: {"id": current_meas, "measurement[blood_glucose_note]": meas_note}
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "update measurement AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "update measurement AJAX Success"
    $('#addBgNoteModal').modal('hide')

  $("#recentMeasTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.target
    loadHealthHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete measurement.")
  )

  $('.hisTitle').click ->
    loadHealthHistory()

  $(".favTitle").click ->
    loadHealthHistory(true)

  $("#recentMeasTable").on("click", "td.measItem", (e) ->
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    meas = data['measurement']
    if(meas.meas_type=="blood_pressure")
      load_measurement_blood_pressure(".measurement_blood_pressure_elem", data)
    else if(meas.meas_type=="blood_sugar")
      load_measurement_blood_glucose(".measurement_blood_glucose_elem", data)
    else if(meas.meas_type=="weight")
      load_measurement_weight(".measurement_weight_elem", data)
    else if(meas.meas_type=="waist")
      load_measurement_waist(".measurement_waist_elem", data)
    else
      console.log("WARN: no measurement type "+meas.meas_type)
  )

  $(document).unbind("click.showHealth")
  $(document).on("click.showHealth", "#health-show-table", (evt) ->
    get_table_row = (item ) ->
      if item.meas_type==null
        return null
      value = ""
      mType = ""
      if item.meas_type == 'blood_pressure'
        mType = meas_types[0]
        if item.systolicbp
          value = item.systolicbp.toString()
        if value != ""
          value = value+"/"
        if item.diastolicbp
          value = value+item.diastolicbp.toString()
        if value != ""
          value = value+" "
        if item.pulse
          value= value+item.pulse.toString()
      else if item.meas_type == 'blood_sugar'
        mType = meas_types[1]
        value = item.blood_sugar + " mmol/L"
      else if item.meas_type == 'weight'
        mType = meas_types[2]
        value = item.weight + " kg"
      else if item.meas_type == 'waist'
        mType = meas_types[3]
        value = item.waist + " cm"
      return ([moment(item.date).format("YYYY-MM-DD HH:MM"), mType, value])

    current_user = $("#current-user-id")[0].value
    lang = $("#data-lang-health")[0].value
    meas_header = $("#meas_header_values").val().split(" ")
    meas_types = $("#meas_types").val().split(",")
    url = 'users/' + current_user + '/measurements.json'+'?lang='+lang
    $.ajax urlPrefix()+url,
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "datatable measurements AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        tblData = $.map(data, (item) ->
          return([get_table_row(item)])
        ).filter( (v) ->
          return(v!=null)
        )
        if lang == 'hu'
          plugin = {
            sEmptyTable: "Nincs rendelkezésre álló adat",
            sInfo: "Találatok: _START_ - _END_ Összesen: _TOTAL_",
            sInfoEmpty: "Nulla találat",
            sInfoFiltered: "(_MAX_ összes rekord közül szűrve)",
            sInfoPostFix: "",
            sInfoThousands: " ",
            sLengthMenu: "_MENU_ találat oldalanként",
            sLoadingRecords: "Betöltés...",
            sProcessing: "Feldolgozás...",
            sSearch: "Keresés:",
            sZeroRecords: "Nincs a keresésnek megfelelő találat",
            oPaginate: {
              sFirst: "Első",
              sPrevious: "Előző",
              sNext: "Következő",
              sLast: "Utolsó"
            },
            oAria: {
              sSortAscending: ": aktiválja a növekvő rendezéshez",
              sSortDescending: ": aktiválja a csökkenő rendezéshez"
            }
          }
        $("#health-data-container").html("<table id=\"health-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>")
        $("#health-data").dataTable({
          "data": tblData,
          "columns": [
            {"title": meas_header[0]},
            {"title": meas_header[1]},
            {"title": meas_header[2]}
          ],
          "order": [[1, "desc"]],
          "lengthMenu": [10],
          "language": plugin
        })
        location.href = "#openModal"
  )

  $(document).unbind("click.downloadHealth")
  $(document).on("click.downloadHealth", "#download-health-data", (evt) ->
    current_user = $("#current-user-id")[0].value
    lang = $("#data-lang-health")[0].value
    url = '/users/' + current_user + '/measurements.csv?order=desc'+'&lang='+lang
    location.href = url
  )

  $(document).unbind("click.closeHealth")
  $(document).on("click.closeHealth", "#close-health-data", (evt) ->
    $("#health-data-container").html("")
    location.href = "#close"
  )

@validateBgInterval = (formId, measId) ->
  formNode = document.getElementById(formId)
  formType = formNode.querySelector("input[name='measurement[meas_type]']").value
  fn = {
    blood_sugar: ((node) ->
      if (!isempty("#profile_glucose_min") && !isempty("#profile_glucose_max")) && ($("#glucose")[0].value < $("#profile_glucose_min")[0].value || $("#glucose")[0].value > $("#profile_glucose_max")[0].value)
        $('#measIdToNote').val(measId)
        $('#addBgNoteModal').modal('show')
    )
  }
  if fn[formType]
    return fn[formType](formNode)
  else
    console.log "WARN: missing validation function for "+formType
    return true
    
@validate_measurement_form = (formSel) ->
  formNode = $(formSel)[0]
  formType = $(formSel+" input[name='measurement[meas_type]']").val()
  fn = {
    blood_pressure: ((node) ->
      if (isempty("#bp_sys") && isempty("#bp_dia") && isempty("#bp_hr")) ||
      (!isempty("#bp_sys") && isempty("#bp_dia")) ||
      (isempty("#bp_sys") && !isempty("#bp_dia")) ||
      (notpositive("#bp_sys") || notpositive("#bp_dia") || notpositive("#bp_hr"))
        popup_error(popup_messages.invalid_health_hr, "healthStyle")
        return false
      return true
    ),
    blood_sugar: ((node) ->
      if isempty("#glucose") || notpositive("#glucose")
        popup_error(popup_messages.invalid_health_bg, "healthStyle")
        return false
      return true
    ),
    weight: ((node) ->
      if isempty("#weight") || notpositive("#weight")
        popup_error(popup_messages.invalid_health_wd, "healthStyle")
        return false
      return true
    ),
    waist: ((node) ->
      if isempty("#waist") || notpositive("#waist")
        popup_error(popup_messages.invalid_health_cd, "healthStyle")
        return false
      return true
    )
  }
  if fn[formType]
    return fn[formType](formNode)
  else
    console.log "WARN: missing validation function for "+formType
    retrn true

@resetMeasForm = () ->
  console.log "reset meas form"

@initMeasurement = () ->
  user_lang = $("#user-lang")[0].value
  if !user_lang
    user_lang='hu'
  measurement_note_select = $("#measNote")
  for element in getStored('sd_meas_'+user_lang)
    measurement_note_select.append($("<option />").val(element.id).text(element.label))

  $('.defaultDatePicker').datetimepicker(timepicker_defaults)

  stressList = $("#stressList").val().split(",")
  $(".bg_stress_scale").slider({
    min: 0,
    max: 3,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".bg_stress_percent").innerHTML = stressList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".bg_stress_amount").value = ui.value
  })
  $(".bg_stress_amount").val(1)

  bgTimeList = $("#bgTimeList").val().split(",")
  $(".bg_time_scale").slider({
    min: 0,
    max: 2,
    value: 0
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".bg_time_unit").innerHTML = bgTimeList[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector(".bg_time_val").value = ui.value
  })
  $(".bg_time_scale").slider({value: 0})

  $('.bp_sys').focus()

@loadHealthHistory = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  lang = $("#data-lang-health")[0].value
  url = 'users/' + current_user + '/measurements.js?source='+window.default_source+'&order=desc&limit=20&lang='+lang
  if fav
    url = url+"&favourites=true"
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent measurements AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      if fav
        $(".deleteMeas").addClass("hidden")
      else
        $(".deleteMeas").removeClass("hidden")

  if fav
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")
  else
    $(".hisTitle").addClass("selected")
    $(".favTitle").removeClass("selected")


@load_measurement_blood_pressure = (sel, data) ->
  meas = data['measurement']
  $(sel+" input[name='measurement[systolicbp]']").val(meas.systolicbp)
  $(sel+" input[name='measurement[diastolicbp]']").val(meas.diastolicbp)
  $(sel+" input[name='measurement[pulse]']").val(meas.pulse)
  $(sel+" input[name='measurement[date]']").val(moment().format(moment_fmt))

@load_measurement_blood_glucose = (sel, data) ->
  meas = data['measurement']
  stressList = $("#stressList").val().split(",")
  bgTimeList = $("#bgTimeList").val().split(",")
  $(sel+" .bg_stress_scale").val(meas.stress_amount)
  $(sel+" .bg_time_scale").val(meas.blood_sugar_time)

  $(sel+" .bg_stress_percent").html(stressList[meas.stress_amount])
  $(sel+" .bg_stress_scale").slider({value: meas.stress_amount})

  $(sel+" .bg_time_unit").html(bgTimeList[meas.blood_sugar_time])
  $(sel+" .bg_time_scale").slider({value: meas.blood_sugar_time})

  if meas.blood_sugar
    $(sel+" input[name='measurement[blood_sugar]']").val(parseFloat(meas.blood_sugar).toFixed(2))
  else
    $(sel+" input[name='measurement[blood_sugar]']").val("")

  $(sel+" input[name='measurement[date]']").val(moment().format(moment_fmt))

@load_measurement_weight = (sel, data) ->
  meas = data['measurement']
  $(sel+" input[name='measurement[weight]']").val(meas.weight)
  $(sel+" input[name='measurement[date]']").val(moment().format(moment_fmt))

@load_measurement_waist= (sel, data) ->
  meas = data['measurement']
  $(sel+" input[name='measurement[waist]']").val(meas.waist)
  $(sel+" input[name='measurement[date]']").val(moment().format(moment_fmt))

@load_meas_types = (cb) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load meas types"
  user_lang = $("#user-lang")[0].value
  db_version = $("#db-version")[0].value
  if user_lang
    measkey = 'sd_meas_'+user_lang
  else
    measkey = 'sd_meas_hu'
  if getStored(measkey)==undefined || getStored(measkey).length==0 || testDbVer(db_version,['sd_meas_hu','sd_meas_en'])
    ret = $.ajax '/measurement_types.json',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load measurement_types AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "load measurement_types  Successful AJAX call"

        setStored('sd_meas_hu', data.filter( (d) ->
          d['category'] == "note"
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))

        setStored('sd_meas_en', data.filter( (d) ->
          d['category'] == "note"
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))

        setStored('db_version', db_version)

        cb()
  else
    ret = new Promise( (resolve, reject) ->
      console.log "measurements already downloaded"
      cb()
      resolve("measurements cbs called")
    )
  return ret
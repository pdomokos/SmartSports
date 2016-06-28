@exercise_loaded = () ->
  uid = $("#current-user-id")[0].value

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#exercise-link").css
    background: "rgba(238, 152, 67, 0.3)"

  popup_messages = JSON.parse($("#popup-messages").val())

  document.body.style.cursor = 'wait'
  loadActivityTypes( () ->
    document.body.style.cursor = 'auto'
    initActivity()
    loadExerciseHistory()
  )

  $("#exercise-create-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    @intensities = $("#intensity_values").val().split(" ")

    $("#"+form_id+" input.dataFormField").val("")

    $('.activity_exercise_scale').slider({value: 1})
    $('.activity_exercise_percent').html(@intensities[1])
    $('.activity_exercise_start_datepicker').val(moment().subtract(30,'minutes').format(moment_fmt))
    $('.activity_exercise_end_datepicker').val(moment().format(moment_fmt))
    $('#activity_type_id').val(null)

    loadExerciseHistory()
    console.log data
    if data['cal_message'] && data['cal_message'] != ""
      popup_success(get_label(data['name'])+popup_messages.saved_successfully+'! ', "exerciseStyle", data['cal_message'])
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log(xhr)
    popup_error(popup_messages.failed_to_add+get_label(xhr.responseJSON.data)+' '+xhr.responseJSON.msg, "exerciseStyle")
  )

  $("#regular-activity-create-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    $("#"+form_id+" input.dataFormField").val("")
    $('.activity_regular_start_datepicker').val(moment().subtract(30,'minutes').format(moment_fmt))
    $('.activity_regular_end_datepicker').val(moment().format(moment_fmt))
    $('#activity_other_type_id').val(null)

    loadExerciseHistory()
    console.log data
    if data['cal_message'] && data['cal_message'] != ""
      popup_success(data['activity_name']+popup_messages.saved_successfully+'! ', "exerciseStyle", data['cal_message'])
  ).on("ajax:error", (e, xhr, status, error) ->
    popup_error(popup_messages.failed_to_add+$("#otheractivityname").val()+' '+xhr.responseJSON.msg, "exerciseStyle")
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item
    loadExerciseHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, "exerciseStyle")
  )

  $('.hisTitle').click ->
    loadExerciseHistory()

  $(".favTitle").click ->
    load_exercise(true)
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

  $("#recentResourcesTable").on("click", "td.activityItem", (e) ->
    data = JSON.parse(e.currentTarget.querySelector("input").value)
    if data.activity_category=="sport"
      load_activity_exercise(".formElement.activity_exercise_elem", data)
  )

  $(document).unbind("click.exerciseShow")
  $(document).on("click.exerciseShow", "#exercise-show-table", (evt) ->
    current_user = $("#current-user-id")[0].value
    lang = $("#user-lang")[0].value
    exercise_header = $("#header_values").val().split(",")
    url = 'users/' + current_user + '/activities.json'+'?table=true&lang='+lang
    show_table(url, lang, exercise_header, 'get_exercise_table_row', 'show_exercise_table')
  )

  $(document).unbind("click.downloadExercise")
  $(document).on("click.downloadExercise", "#download-exercise-data", (evt) ->
    current_user = $("#current-user-id")[0].value
    lang = $("#user-lang")[0].value
    url = '/users/' + current_user + '/activities.csv?order=desc&lang='+lang
    location.href = url
  )

  $(document).unbind("click.closeExercise")
  $(document).on("click.closeExercise", "#close-exercise-data", (evt) ->
    $("#exercise-data-container").html("")
    location.href = "#close"
  )
  
@initActivity = (selector) ->
  intensities = $("#intensity_values").val().split(" ")
  console.log "initActivity called, selector="+selector
  self = this
  if selector==null||selector==undefined
    selector = ""
  else
    selector = selector+" "

  $(selector+".activity_exercise_scale").slider({
    min: 0,
    max: 2,
    value: 1
  }).slider({
    slide: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("div.activity_exercise_percent").innerHTML = intensities[ui.value]
#      $(".activity_exercise_percent").html(intensities[ui.value])
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("input.activity_exercise_intensity").value = ui.value
#      $(".activity_exercise_intensity").val(ui.value)
  })

  $(selector+".activity_regular_scale").slider({
    min: 0,
    max: 2,
    value: 1
  }).slider({
    slide: (event, ui) ->
      console.log event.target
      event.target.parentElement.parentElement.querySelector("div.activity_regular_percent").innerHTML = intensities[ui.value]
    change: (event, ui) ->
      event.target.parentElement.parentElement.querySelector("input.activity_regular_intensity").value = ui.value
  })

  $(selector+'.activity_exercise_start_datepicker').datetimepicker(timepicker_defaults)
  $(selector+'.activity_exercise_start_datepicker').on("change.dp", (e) ->
    starttime = $(selector+'.activity_exercise_start_datepicker').val()
    a = moment(starttime).add(30,'minutes').format(moment_fmt)
    $(selector+'.activity_exercise_end_datepicker').val(a)
  )
  $(selector+'.activity_exercise_end_datepicker').datetimepicker(timepicker_defaults)

  $(selector+'.activity_regular_start_datepicker').datetimepicker(timepicker_defaults)
  $(selector+'.activity_regular_end_datepicker').datetimepicker(timepicker_defaults)

  user_lang = $("#user-lang")[0].value
  activity_exercise_select = $(".activity_exercise_name")
  if user_lang
    exercisekey = 'sd_activities_'+user_lang
  else
    exercisekey = 'sd_activities_hu'
  for element in getStored(exercisekey)
    activity_exercise_select.append($("<option />").val(element.id).text(element.label))

@loadExerciseHistory = () ->
  load_exercise()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@load_exercise = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent exercises"
  lang = $("#data-lang-training")[0].value
  url = 'users/' + current_user + '/activities.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax urlPrefix()+url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent activities AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      if fav
        $(".deleteExercise").addClass("hidden")
      else
        $(".deleteExercise").removeClass("hidden")
      console.log "load recent activities  Successful AJAX call"

@loadActivityTypes = (cb) ->
  self = this
  @intensities = $("#intensity_values").val().split(" ")
  user_lang = $("#user-lang")[0].value
  db_version = $("#db-version")[0].value
  console.log db_version
  console.log "calling load activity types"

  if user_lang
    activity_key = 'sd_activities_'+user_lang
  else
    activity_key = 'sd_activities_hu'

  if getStored(activity_key)==undefined || getStored(activity_key).length==0 || testDbVer(db_version,['sd_activities_hu','sd_activities_en'])
    ret = $.ajax urlPrefix()+'activity_types.json',
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load activity_types AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "load activity_types  Successful AJAX call"

        setStored('sd_activities_hu', data.filter( (d) ->
          d['category'] == 'sport'
        ).map( (d) ->
          {
          label: d['hu'],
          id: d['name']
          }))

        setStored('sd_activities_en', data.filter( (d) ->
          d['category'] == 'sport'
        ).map( (d) ->
          {
          label: d['en'],
          id: d['name']
          }))

        setStored('db_version', db_version)
        cb()
  else
    ret = new Promise( (resolve, reject) ->
      console.log "activities already downloaded"
      cb()
      resolve("cbs called")
    )
  return ret



@load_activity_exercise = (sel, data) ->
  console.log "load activity, sel="+sel
  console.log(data)
  activity = data['activity']
  $(sel+" .activity_exercise_name").val(data['activity_name'])
  $(sel+" input[name='activity[intensity]']").val(activity.intensity)
  $(sel+" .activity_exercise_percent").html(@intensities[activity.intensity])
  $(sel+" .activity_exercise_scale").slider({value: activity.intensity})
  diff = moment(activity.start_time).diff(moment(activity.end_time))
  curr = moment()
  f = curr.format(moment_fmt)
  t = curr.add(diff).format(moment_fmt)
  $(sel+" input[name='activity[start_time]']").val(t)
  $(sel+" input[name='activity[end_time]']").val(f)

@exercise_loaded = () ->
  uid = $("#current-user-id")[0].value

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#exercise-link").css
    background: "rgba(238, 152, 67, 0.3)"

  popup_messages = JSON.parse($("#popup-messages").val())

  initExercise()
  document.body.style.cursor = 'wait'
  loadExerciseHistory()

  $(document).on("click", "#exercise-show-table", (evt) ->
    console.log "datatable clicked"
    current_user = $("#current-user-id")[0].value
    url = '/users/' + current_user + '/activities.json'
    $.ajax url,
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "datatable activity AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        tblData = $.map(data.activities,(item,i) ->
          return([get_exercise_table_row(item)])
        ).filter( (v) ->
          return(v!=null)
        )
        $("#exercise-data-container").html("<table id=\"exercise-data\" class=\"display\" cellspacing=\"0\" width=\"100%\"></table>")
        $("#exercise-data").dataTable({
          "data": tblData,
          "columns": [
            {"title": "id"},
            {"title": "date"},
            {"title": "name"},
            {"title": "intensity"},
            {"title": "duration"}
          ],
          "order": [[1, "desc"]],
          "lengthMenu": [10]
        })
        location.href = "#openModalEx"
  )
  $(document).on("click", "#download-exercise-data", (evt) ->
    current_user = $("#current-user-id")[0].value
    url = '/users/' + current_user + '/activities.csv?order=desc'
    location.href = url
  )
  $(document).on("click", "#close-exercise-data", (evt) ->
    $("#exercise-data-container").html("")
    location.href = "#close"
  )

@get_exercise_table_row = (item ) ->
  if item.activity==null || !item.intensity || !item.duration
    return null
  return ([item.id, moment(item.start_time).format("YYYY-MM-DD HH:MM"), item.activity, item.intensity, item.duration])

@initExercise = () ->
  console.log "init exercise"
  popup_messages = JSON.parse($("#popup-messages").val())
  @intensities = $("#intensity_values").val().split(" ")

  $(".activity_exercise_scale").slider({
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

  $(".activity_regular_scale").slider({
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

  $('.activity_exercise_start_datepicker').datetimepicker(timepicker_defaults)
  $('.activity_exercise_end_datepicker').datetimepicker(timepicker_defaults)

  $('.activity_regular_start_datepicker').datetimepicker(timepicker_defaults)
  $('.activity_regular_end_datepicker').datetimepicker(timepicker_defaults)

  $("#exercise-create-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    $("#"+form_id+" input.dataFormField").val("")
    $('#activity_start_datepicker').val(moment().subtract(30,'minutes').format(moment_fmt))
    $('#activity_end_datepicker').val(moment().format(moment_fmt))
    $('#activity_type_id').val(null)

    loadExerciseHistory()
    console.log data
    popup_success(data['activity_name']+popup_messages.saved_successfully, $("#addActivityButton").css("background"))
  ).on("ajax:error", (e, xhr, status, error) ->
    popup_error(popup_messages.failed_to_add+$("#activityname").val(), $("#addActivityButton").css("background"))
  )

  $("#regular-activity-create-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    $("#"+form_id+" input.dataFormField").val("")
    $('#activity_other_start_datepicker').val(moment().subtract(30,'minutes').format(moment_fmt))
    $('#activity_other_end_datepicker').val(moment().format(moment_fmt))
    $('#activity_other_type_id').val(null)

    loadExerciseHistory()
    console.log data
    popup_success(data['activity_name']+popup_messages.saved_successfully, $("#addActivityButton").css("background"))
  ).on("ajax:error", (e, xhr, status, error) ->
    popup_error(popup_messages.failed_to_add+$("#otheractivityname").val(), $("#addActivityButton").css("background"))
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item
    loadExerciseHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error(popup_messages.failed_to_delete_data, $("#addActivityButton").css("background"))
  )

  $('.hisTitle').click ->
    loadExerciseHistory()

  $(".favTitle").click ->
    load_exercise(true)
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

  load_activity_types()

@loadExerciseHistory = () ->
  load_exercise()
  $(".hisTitle").addClass("selected")
  $(".favTitle").removeClass("selected")

@load_exercise = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent exercises"
  lang = $("#data-lang-training")[0].value
  url = '/users/' + current_user + '/activities.js?source='+window.default_source+'&order=desc&limit=10&lang='+lang
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent activities AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      if fav
        $(".deleteExercise").addClass("hidden")
      else
        $(".deleteExercise").removeClass("hidden")
      console.log "load recent activities  Successful AJAX call"
      console.log textStatus

@load_activity_types = () ->
  self = this
  current_user = $("#current-user-id")[0].value
#  intensities = $("#intensity_values").val().split(" ")
  console.log "calling load activity types"
  $.ajax '/activity_types.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load activity_types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load activity_types  Successful AJAX call"

      activities = data.filter( (d) ->
        d['category'] == 'sport'
      ).map( (d) ->
        {
        label: d['name'],
        id: d['id']
        })
      other_activities = data.filter( (d) ->
        d['category'] == 'custom'
      ).map( (d) ->
        {
        label: d['name'],
        id: d['id']
        })
      popup_messages = JSON.parse($("#popup-messages").val())
      activitySelected = null
      $(".activity_exercise_name").autocomplete({
        minLength: 0,
        source: (request, response) ->
          matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
          result = []
          cnt = 0
          for element in activities
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
          response(result)
        select: (event, ui) ->
          $(".activity_exercise_type_id").val(ui.item.id)
          $(".activity_exercise_scale" ).slider({
            value: "1"
          })
          $(".activity_exercise_percent").text(intensities[1])
        create: (event, ui) ->
          document.body.style.cursor = 'auto'
          $(".activity_exercise_name").removeAttr("disabled")
        change: (event, ui) ->
          activitySelected = ui['item']
          console.log "activity change"
          console.log ui['item']
      }).focus ->
        $(this).autocomplete("search")

      otherActivitySelected = null
      $(".activity_regular_name").autocomplete({
        minLength: 0,
        source: (request, response) ->
          matcher = new RegExp($.ui.autocomplete.escapeRegex(remove_accents(request.term), ""), "i")
          result = []
          cnt = 0
          for element in other_activities
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
          response(result)
        select: (event, ui) ->
          $(".activity_regular_type_id").val(ui.item.id)
          $(".activity_regular_scale" ).slider({
            value: "1"
          })
          $(".activity_regular_percent").text(intensities[1])
        create: (event, ui) ->
          $(".activity_regular_name").removeAttr("disabled")
        change: (event, ui) ->
          otherActivitySelected = ui['item']
      }).focus ->
        $(this).autocomplete("search")

      load_fn =  (e) ->
        console.log "loading activity"
        data = JSON.parse(e.currentTarget.querySelector("input").value)
        console.log data
        if data.activity_category=="sport"
          load_activity_exercise(".activity_exercise_elem", data)
        else if data.activity_category!="sport"
          otherActivitySelected = data.activity_name
          load_activity_regular(".activity_regular_elem", data)
      $("#recentResourcesTable").on("click", "td.activityItem", load_fn)

@load_activity_exercise = (sel, data) ->
  activity = data['activity']
  $(sel+" .activity_exercise_name").val(data.activity_name)
  $(sel+" .activity_exercise_type_id").val(activity.activity_type_id)
  $(sel+" .activity_exercise_intensity").val(activity.intensity)
  $(sel+" .activity_exercise_percent").html(intensities[activity.intensity])
  $(sel+" .activity_exercise_scale").slider({value: activity.intensity})
  $(sel+" input[name='activity[start_time]']").val(fixdate(activity.start_time))
  $(sel+" input[name='activity[end_time]']").val(fixdate(activity.end_time))

@load_activity_regular= (sel, data) ->
  activity = data['activity']
  $(sel+" .activity_regular_name").val(data.activity_name)
  $(sel+" .activity_regular_type_id").val(activity.activity_type_id)
  $(sel+" .activity_regular_intensity").val(activity.intensity)
  $(sel+" .activity_regular_percent").html(intensities[activity.intensity])
  $(sel+" .activity_regular_scale").slider({value: activity.intensity})
  $(sel+" input[name='activity[start_time]']").val(fixdate(activity.start_time))
  $(sel+" input[name='activity[end_time]']").val(fixdate(activity.end_time))

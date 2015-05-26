@exercise_loaded = () ->
  uid = $("#current-user-id")[0].value

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#exercise-link").addClass("selected")

  init_exercise()

  document.body.style.cursor = 'wait'
  loadExerciseHistory()

  load_activity_types()

init_exercise = () ->
  intensities = $("#intensity_values").val().split(" ")
  console.log "init exercise"
  console.log intensities
  $("#activity_scale").slider({
    min: 1,
    max: 3,
    value: 2
  }).slider({
    slide: (event, ui) ->
      if ui.value == 1
        $("#activity_percent").html(intensities[0])
      else if ui.value == 2
        $("#activity_percent").html(intensities[1])
      else if ui.value == 3
        $("#activity_percent").html(intensities[2])
    change: (event, ui) ->
      $("#activity_intensity").val(ui.value)
  })

  $("#activity_other_scale").slider({
    min: 1,
    max: 3,
    value: 2
  }).slider({
    slide: (event, ui) ->
      if ui.value == 1
        $("#activity_other_percent").html(intensities[0])
      else if ui.value == 2
        $("#activity_other_percent").html(intensities[1])
      else if ui.value == 3
        $("#activity_other_percent").html(intensities[2])
    change: (event, ui) ->
      $("#activity_other_intensity").val(ui.value)
  })

  $('#activity_start_datepicker').datetimepicker(timepicker_defaults)
  $('#activity_end_datepicker').datetimepicker(timepicker_defaults)

  $('#activity_other_start_datepicker').datetimepicker(timepicker_defaults)
  $('#activity_other_end_datepicker').datetimepicker(timepicker_defaults)
#  $('#running_datepicker').datetimepicker(timepicker_defaults)

  $("#exercise-create-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    $("#"+form_id+" input.dataFormField").val("")
    $('#activity_start_datepicker').val(moment().subtract(30,'minutes').format(moment_fmt))
    $('#activity_end_datepicker').val(moment().format(moment_fmt))
    $('#activity_type_id').val(null)

    loadExerciseHistory()
    console.log data
    popup_success(data['activity_name']+" saved successfully")
  ).on("ajax:error", (e, xhr, status, error) ->
    $('#activity_type_id').val(null)
    popup_error("Failed to create "+$("#activityname").val())
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
    popup_success(data['activity_name']+" saved successfully")
  ).on("ajax:error", (e, xhr, status, error) ->
    $('#activity_type_id').val(null)
    $('#activity_other_type_id').val(null)
    popup_error("Failed to create "+$("#otheractivityname").val())
  )

  $("#recentResourcesTable").on("ajax:success", (e, data, status, xhr) ->
    form_item = e.currentTarget
    console.log "delete success "+form_item
    loadExerciseHistory()
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    popup_error("Failed to delete activity")
  )

  $('.hisTitle').click ->
    loadExerciseHistory()

  $(".favTitle").click ->
    load_exercise(true)
    $(".hisTitle").removeClass("selected")
    $(".favTitle").addClass("selected")

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
  intensities = $("#intensity_values").val().split(" ")
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

      activitySelected = null
      $("#activityname").autocomplete({
        minLength: 0
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
          $("#activity_type_id").val(ui.item.id)
          $("#activity_scale" ).slider({
            value: "2"
          })
          $("#activity_percent").text(intensities[1])
        create: (event, ui) ->
          document.body.style.cursor = 'auto'
          $("#activityname").removeAttr("disabled")
        change: (event, ui) ->
          activitySelected = ui['item']
          console.log "activity change"
          console.log ui['item']
      }).focus ->
        $(this).autocomplete("search")

      $("#exercise-create-form button").click ->
        if(!activitySelected)
          val = $("#activityname").val()
          if !val
            val = "empty item"
          popup_error("Failed to add "+val)
          activitySelected = null
          return false
        activitySelected = null
        return true

      otherActivitySelected = null
      $("#otheractivityname").autocomplete({
        minLength: 0
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
          $("#activity_other_type_id").val(ui.item.id)
          $("#activity_other_scale" ).slider({
            value: "2"
          })
          $("#activity_other_percent").text(intensities[1])
        create: (event, ui) ->
          $("#otheractivityname").removeAttr("disabled")
        change: (event, ui) ->
          otherActivitySelected = ui['item']
      }).focus ->
        $(this).autocomplete("search")

      $("#regular-activity-create-form button").click ->
        if(!otherActivitySelected)
          val = $("#otheractivityname").val()
          if !val
            val = "empty item"
          popup_error("Failed to add "+val)
          otherActivitySelected = null
          return false
        otherActivitySelected = null
        return true

      load_fn =  (e) ->
        console.log "loading activity"
        data = JSON.parse(e.currentTarget.querySelector("input").value)
        console.log data
        if data.activity_category=="sport"
          activitySelected = data.activity_name
          $("#activityname").val(data.activity_name)
          $("#activity_type_id").val(data.activity_type_id)
          $("#activity_intensity").val(data.intensity)
          if data.intensity == 1
            $("#activity_percent").html(intensities[0])
          else if data.intensity == 2
            $("#activity_percent").html(intensities[1])
          else if data.intensity == 3
            $("#activity_percent").html(intensities[2])
          $("#activity_scale").slider({value: data.intensity})
        else if data.activity_category!="sport"
          otherActivitySelected = data.activity_name
          $("#otheractivityname").val(data.activity_name)
          $("#activity_other_type_id").val(data.activity_type_id)
          $("#activity_other_intensity").val(data.intensity)
          if data.intensity == 1
            $("#activity_other_percent").html(intensities[0])
          else if data.intensity == 2
            $("#activity_other_percent").html(intensities[1])
          else if data.intensity == 3
            $("#activity_other_percent").html(intensities[2])
          $("#activity_other_scale").slider({value: data.intensity})
      $("#recentResourcesTable").on("click", "td.activityItem", load_fn)
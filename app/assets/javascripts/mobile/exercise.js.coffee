@exercise_loaded = () ->
  $("#exercise-link").css
    background: "rgba(238, 152, 67, 0.3)"
  init_exercise()
  load_exercise()
  load_activity_types()

init_exercise = () ->
  $('#activity_start_datepicker').datetimepicker(timepicker_defaults)
  $('#activity_end_datepicker').datetimepicker(timepicker_defaults)
  $('#activity_other_start_datepicker').datetimepicker(timepicker_defaults)
  $('#activity_other_end_datepicker').datetimepicker(timepicker_defaults)

  $(document).on("ajax:success", "#exercise-create-form", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log xhr.responseText
    $("#activityname").val("")
    $('#activity_start_datepicker').val(moment().subtract(30,'minutes').format(moment_fmt))
    $('#activity_end_datepicker').val(moment().format(moment_fmt))
    $('#activity_type_id').val(null)
    $("#activity_scale").val(2).slider("refresh")

    load_exercise()
    $("#successExercisePopup").popup("open")

  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    $("#failureExercisePopup").popup("open")
  )

  $(document).on("ajax:success", "#regular-activity-create-form", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log xhr.responseText
    $("#otheractivityname").val("")
    $('#activity_other_start_datepicker').val(moment().subtract(30,'minutes').format(moment_fmt))
    $('#activity_other_end_datepicker').val(moment().format(moment_fmt))
    $('#activity_other_type_id').val(null)
    $("#activity_other_scale").val(2).slider("refresh")
    load_exercise()
    $("#successExercisePopup").popup("open")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    $("#failureExercisePopup").popup("open")
  )
  $(document).on("ajax:success", "#updateExerciseForm", (e, data, status, xhr) ->
    console.log("update successfull")
    $("#exercisePage").attr("data-scrolltotable", true)
    $( ":mobile-pagecontainer" ).pagecontainer("change", "#exercisePage")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to update exercise.")
  )
  $(document).on("ajax:success", "#deleteExerciseForm", (e, data, status, xhr) ->
    console.log("delete successfull")
    $("#exercisePage").attr("data-scrolltotable", true)
    $.mobile.navigate( "#exercisePage" )
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete exercise.")
  )

  $("#exercisePage").on("click" , ".recentResourcesListview td.activity_item", load_activity_item)

  $('#hist-exercise-button').click ->
    load_exercise()

  $("#fav-exercise-button").click ->
    load_exercise(true)

  $(document).on("pagecontainershow", (event, ui) ->
    console.log("activity pagecontainershow")
    load_exercise()
  )

load_activity_item =  (e) ->
  console.log "loading activity"
  console.log e
  data = JSON.parse(e.currentTarget.querySelector("input").value)
  console.log data
  if data.activity_category=="sport"
    $("#activityname").val(data.activity_name)
    $("#activity_type_id").val(data.activity_type_id)
    $("#activity_intensity").val(data.intensity)
    $("#activity_scale").val(data.intensity).slider("refresh")
  else if data.activity_category!="sport"
    $("#otheractivityname").val(data.activity_name)
    $("#activity_other_type_id").val(data.activity_type_id)
    $("#activity_other_intensity").val(data.intensity)
    $("#activity_other_scale").val(data.intensity).slider("refresh")

@load_exercise = (fav=false) ->
  self = this
  current_user = $("#current-user-id")[0].value
  console.log "calling load recent exercises"
  lang = $("#data-lang-training")[0].value
  url = '/users/' + current_user + '/activities.js?source='+window.default_source+'&order=desc&limit=10&mobile=true'
  if lang
    url = url+"&lang="+lang
  if fav
    console.log "loading favorites"
    url = url+"&favourites=true"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent activities AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent activities  Successful AJAX call"
      console.log textStatus
      if fav
        $("#hist-button").removeClass("ui-btn-active")
        $("#fav-button").addClass("ui-btn-active")
      else
        $("#hist-button").addClass("ui-btn-active")
        $("#fav-button").removeClass("ui-btn-active")
      if $("#exercisePage").attr('data-scrolltotable')
        $.mobile.silentScroll($("div.ui-navbar").offset().top)
        $("#exercisePage").attr('data-scrolltotable', null)


@load_activity_types = () ->
  self = this
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

      $( "#activity_autocomplete" ).on( "filterablebeforefilter",  ( e, data ) ->
        $ul = $( this )
        $input = $( data.input )
        value = $input.val()

        html = ""
        $ul.html( "" )
        if ( value )
          $ul.html( "<li><div class='ui-loader'><span class='ui-icon ui-icon-loading'></span></div></li>" )
          $ul.listview( "refresh" )
          matcher = new RegExp(remove_accents(value), "i")
          result = []
          cnt = 0
          for element in activities
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
            if cnt >= 6
              break

          console.log result
          $.each( result, ( i, val ) ->
            html += "<li id='activity_id_"+val.id+"'>" + val.label + "</li>";
          )
          $ul.html( html );
          $ul.listview( "refresh" );
          $ul.trigger( "updatelayout")
      )

      $("#activity_autocomplete").on("click", "li", (e) ->
        $("#activityname").val($(this).text())
        $("#activity_autocomplete").html("")
        [..., activity_id] = $(this)[0].id.split("_")
        $("#activity_type_id").val( activity_id )
        console.log $(this).text()+" id: "+activity_id
      )

      $( "#activity_other_autocomplete" ).on( "filterablebeforefilter",  ( e, data ) ->
        $ul = $( this )
        $input = $( data.input )
        value = $input.val()

        html = ""
        $ul.html( "" )
        if ( value )
          $ul.html( "<li><div class='ui-loader'><span class='ui-icon ui-icon-loading'></span></div></li>" )
          $ul.listview( "refresh" )

          matcher = new RegExp(remove_accents(value), "i")
          result = []
          cnt = 0
          for element in other_activities
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
            if cnt >= 6
              break

          console.log result
          $.each( result, ( i, val ) ->
            html += "<li id='activity_id_"+val.id+"'>" + val.label + "</li>";
          )
          $ul.html( html );
          $ul.listview( "refresh" );
          $ul.trigger( "updatelayout")
      )

      $("#activity_other_autocomplete").on("click", "li", (e) ->
        $("#otheractivityname").val($(this).text())
        $("#activity_other_autocomplete").html("")
        [..., activity_id] = $(this)[0].id.split("_")
        $("#activity_other_type_id").val( activity_id )
        console.log $(this).text()+" id: "+activity_id
      )

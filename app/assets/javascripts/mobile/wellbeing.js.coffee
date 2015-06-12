@wellbeing_loaded = () ->
  $("#wellbeing-link").css
    background: "rgba(232, 115, 180, 0.3)"

  $('#sleep_start_datepicker').datetimepicker(timepicker_defaults)
  $('#sleep_end_datepicker').datetimepicker(timepicker_defaults)
  $('#pain_start_datepicker').datetimepicker(timepicker_defaults)
  $('#pain_end_datepicker').datetimepicker(timepicker_defaults)
  $('#stress_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('#illness_start_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('#illness_end_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('#periods_start_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $('#periods_end_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  sleepList = $("#sleepList").val().split(",")
  stressList = $("#stressList").val().split(",")
  illnessList = $("#illnessList").val().split(",")
  painList = $("#painList").val().split(",")
  periodPainList = $("#periodPainList").val().split(",")
  periodVolumeList = $("#periodVolumeList").val().split(",")
  painTypeList = $("#painTypeList").val().split(",")

  load_illness_types()
  load_lifestyles_m()

  $(document).on("ajax:success", "form.resource-create-form.lifestyle-form", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log xhr.responseText
    $('#sleep_start_datepicker').val(moment().format(moment_fmt))
    $('#sleep_end_datepicker').val(moment().format(moment_fmt))
    $('#stress_datepicker').val(moment().format(moment_fmt))
    $('#illness_start_datepicker').val(moment().format(moment_fmt))
    $('#illness_end_datepicker').val(moment().format(moment_fmt))
    $('#pain_start_datepicker').val(moment().format(moment_fmt))
    $('#pain_end_datepicker').val(moment().format(moment_fmt))
    $('#periods_start_datepicker').val(moment().format(moment_fmt))
    $('#periods_end_datepicker').val(moment().format(moment_fmt))
    $("#sleep_scale").val(2).slider("refresh")
    $("#stress_scale").val(1).slider("refresh")
    $("#illness_scale").val(1).slider("refresh")
    $('#illness_name').val(null)
    $('#illnessname').val(null)
    $("#pain_scale").val(1).slider("refresh")
    $('#pain_name').val(null)
    $('#painname').val(null)
    $("#periods_scale").val(1).slider("refresh")
    $("#periods_volume_scale").val(1).slider("refresh")

    load_lifestyles_m()
    $("#successLifestylePopup").popup("open")

  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    $("#failureLifestylePopup").popup("open")
  )

  $(document).on("ajax:success", "#deleteLifestyle", (e, data, status, xhr) ->
    console.log("delete successfull")
    $("#wellbeingPage").attr("data-scrolltotable", true)
    $.mobile.navigate( "#wellbeingPage" )
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log xhr.responseText
    alert("Failed to delete lifestyle.")
  )

  $(document).on("pagecontainershow", (event, ui) ->
    console.log("activity pagecontainershow")
    load_lifestyles_m()
  )

@load_lifestyles_m = () ->
  self = this
  current_user = $("#current-user-id")[0].value
  lang = $("#data-lang-wellbeing")[0].value
  url = '/users/' + current_user + '/lifestyles.js?source='+window.default_source+'&order=desc&limit=10&mobile=true'
  if lang
    url = url+"&lang="+lang
  console.log "calling load recent lifestyles"
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent lifestyles AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log textStatus
      if $("#wellbeingPage").attr('data-scrolltotable')
        $.mobile.silentScroll($("div.ui-navbar").offset().top)
        $("#wellbeingPage").attr('data-scrolltotable', null)

@load_illness_types = () ->
  self = this
  console.log "calling load illness types"
  $.ajax '/illness_types.json',
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load illness types AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load illness types  Successful AJAX call"

      illnesses = data.map( window.illness_map_fn )
      pains = $("#painTypeList").val().split(",")

      $( "#illness_autocomplete" ).on( "filterablebeforefilter",  ( e, data ) ->
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
          for element in illnesses
            if matcher.test(remove_accents(element.label))
              result.push(element)
              cnt += 1
            if cnt >= 6
              break

          console.log result
          $.each( result, ( i, val ) ->
            html += "<li id='illness_id_"+val.id+"'>" + val.label + "</li>";
          )
          $ul.html( html );
          $ul.listview( "refresh" );
          $ul.trigger( "updatelayout")
      )

      $("#illness_autocomplete").on("click", "li", (e) ->
        $("#illness_name").val($(this).text())
        $("#illness_autocomplete").html("")
        [..., illness_id] = $(this)[0].id.split("_")
        $("#illnessname").val( illness_id )
        console.log $(this).text()+" id: "+illness_id
      )

      $( "#pain_autocomplete" ).on( "filterablebeforefilter",  ( e, data ) ->
        $ul = $( this )
        $input = $( data.input )
        value = $input.val()

        html = ""
        $ul.html( "" )
        if ( value )
          $ul.html( "<li><div class='ui-loader'><span class='ui-icon ui-icon-loading'></span></div></li>" )
          $ul.listview( "refresh" )
          matcher = new RegExp(remove_accents(value), "i")
          result = pains
          console.log result
          $.each( result, ( i, val ) ->
            html += "<li id="+val+">" + val + "</li>";
          )
          $ul.html( html );
          $ul.listview( "refresh" );
          $ul.trigger( "updatelayout")
      )

      $("#pain_autocomplete").on("click", "li", (e) ->
        $("#pain_name").val($(this).text())
        $("#pain_autocomplete").html("")
        [..., pain_id] = $(this)[0].id.split("_")
        $("#painname").val( pain_id )
        console.log $(this).text()+" id: "+pain_id
      )




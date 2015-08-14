

@settings_loaded = () ->
  reset_ui()
  $("#settings-button").addClass("selected")

  $("#myprofile-link").click (event) ->
    event.preventDefault()
    reset_settings_ui()
    $("#myprofile-link").addClass("menulink-selected")
    $("#sectionProfile").removeClass("hiddenSection")

  $("#moves-link").click (event) ->
    event.preventDefault()
    reset_settings_ui()
    $("#moves-link").addClass("menulink-selected")
    $("#sectionMoves").removeClass("hiddenSection")

  $("#googlefit-link").click (event) ->
    event.preventDefault()
    reset_settings_ui()
    $("#googlefit-link").addClass("menulink-selected")
    $("#sectionGooglefit").removeClass("hiddenSection")

  $("#misfit-link").click (event) ->
    event.preventDefault()
    reset_settings_ui()
    $("#misfit-link").addClass("menulink-selected")
    $("#sectionMisfit").removeClass("hiddenSection")

  $("#fitbit-link").click (event) ->
    event.preventDefault()
    reset_settings_ui()
    $("#fitbit-link").addClass("menulink-selected")
    $("#sectionFitbit").removeClass("hiddenSection")

  $("#withings-link").click (event) ->
    event.preventDefault()
    reset_settings_ui()
    $("#withings-link").addClass("menulink-selected")
    $("#sectionWithings").removeClass("hiddenSection")

  $("#admin-link").click (event) ->
    event.preventDefault()
    reset_settings_ui()
    $("#admin-link").addClass("menulink-selected")
    $("#sectionAdmin").removeClass("hiddenSection")

  $("#signin-moves-button").click (event) ->
    event.preventDefault()
    window.location = '/auth/moves'

  $("#disconnect-moves-button").click (event) ->
    event.preventDefault()
    window.location = '/pages/mdestroy'

  $("#signin-withings-button").click (event) ->
    event.preventDefault()
    window.location = '/auth/withings'

  $("#disconnect-withings-button").click (event) ->
    event.preventDefault()
    window.location = '/pages/wdestroy'

  $("#signin-misfit-button").click (event) ->
    event.preventDefault()
    window.location = '/auth/shine'

  $("#disconnect-misfit-button").click (event) ->
    event.preventDefault()
    window.location = '/sync/misfit_destroy'

  $("#signin-fitbit-button").click (event) ->
    event.preventDefault()
    window.location = '/auth/fitbit'

  $("#disconnect-fitbit-button").click (event) ->
    event.preventDefault()
    window.location = '/pages/fdestroy'

  $("#signin-google-button").click (event) ->
    event.preventDefault()
    window.location = '/auth/google_oauth2'

  $("#disconnect-google-button").click (event) ->
    event.preventDefault()
    window.location = '/pages/gfdestroy'

  $("#sync-moves-button").click (event) ->
    failure_message = "Sync failed <i class='fa fa-warning' style='color: red'></i>"
    $("#moves-sync-status").html("Syncing... <i class='fa fa-spinner fa-spin'></i>")
    $('body').addClass('wait');
    $.ajax "/sync/sync_moves",
      type: "GET"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
        $("#moves-sync-status").html(failure_message)
        $('body').removeClass('wait');
      success: (result, textStatus, jqXHR) ->
        console.log "Successful AJAX call"
        console.log result
        if result['status'] == "OK"
          $("#moves-sync-status").html("Synced just now <i class='fa fa-check' style='color: green'></i>")
        else
          $("#moves-sync-status").html(failure_message)
        $('body').removeClass('wait');

  $("#sync-withings-button").click (event) ->
    $("#withings-sync-status").html("Syncing... <i class='fa fa-spinner fa-spin'></i>")
    failure_message = "Sync failed <i class='fa fa-warning' style='color: red'></i>"
    $('body').addClass('wait');
    $.ajax "/sync/sync_withings",
      type: "GET"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
        $("#withings-sync-status").html(failure_message)
        $('body').removeClass('wait');
      success: (result, textStatus, jqXHR) ->
        console.log "Successful AJAX call"
        console.log result
        if result['status'] == "OK"
          $("#withings-sync-status").html("Synced just now <i class='fa fa-check' style='color: green'></i>")
          console.log result['data']
        else
          $("#withings-sync-status").html(failure_message)
        $('body').removeClass('wait');

  $("#sync-misfit-button").click (event) ->
    $("#misfit-sync-status").html("Syncing... <i class='fa fa-spinner fa-spin'></i>")
    failure_message = "Sync failed <i class='fa fa-warning' style='color: red'></i>"
    $('body').addClass('wait');
    $.ajax "/sync/sync_misfit",
      type: "GET"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
        $("#misfit-sync-status").html(failure_message)
        $('body').removeClass('wait');
      success: (result, textStatus, jqXHR) ->
        console.log "Successful AJAX call"
        console.log result
        if result['status'] == "OK"
          $("#misfit-sync-status").html("Synced just now <i class='fa fa-check' style='color: green'></i>")
          console.log result['data']
        else
          $("#misfit-sync-status").html(failure_message)
        $('body').removeClass('wait');

  $("#sync-fitbit-button").click (event) ->
    $("#fitbit-sync-status").html("Syncing... <i class='fa fa-spinner fa-spin'></i>")
    failure_message = "Sync failed <i class='fa fa-warning' style='color: red'></i>"
    $('body').addClass('wait');
    $.ajax "/sync/sync_fitbit",
      type: "GET"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
        $("#fitbit-sync-status").html(failure_message)
        $('body').removeClass('wait');
      success: (result, textStatus, jqXHR) ->
        console.log "Successful AJAX call"
        console.log result
        if result['status'] == "OK"
          $("#fitbit-sync-status").html("Synced just now <i class='fa fa-check' style='color: green'></i>")
          console.log result['data']
        else
          $("#fitbit-sync-status").html(failure_message)
        $('body').removeClass('wait');

  $("#sync-google-button").click (event) ->
    $("#google-sync-status").html("Syncing... <i class='fa fa-spinner fa-spin'></i>")
    failure_message = "Sync failed <i class='fa fa-warning' style='color: red'></i>"
    $('body').addClass('wait');
    $.ajax "/sync/sync_google",
      type: "GET"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
        $("#google-sync-status").html(failure_message)
        $('body').removeClass('wait');
      success: (result, textStatus, jqXHR) ->
        console.log "Successful AJAX call"
        console.log result
        if result['status'] == "OK"
          $("#google-sync-status").html("Synced just now <i class='fa fa-check' style='color: green'></i>")
          console.log result['data']
        else
          $("#google-sync-status").html(failure_message)
        $('body').removeClass('wait');

  popup_messages = JSON.parse($("#popup-messages").val())

  $('#profile_birth_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true,
    maxDate: '0',
    minDate: new Date(1900, 1 - 1, 1)
  })

  $("form.resource-update-form.user-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    $("#"+form_id+" input.dataFormField").val("")
    console.log status
    if JSON.parse(xhr.responseText).status == "NOK"
#      popup_error(popup_messages.failed_to_add_data)
      popup_error(JSON.parse(xhr.responseText).msg)
    else
      popup_success(popup_messages.save_success)
  ).on("ajax:error", (e, data, status, xhr) ->
#    popup_error(popup_messages.failed_to_add_data)
    popup_error(JSON.parse(xhr.responseText).msg)
  )

  $("form.resource-update-form.profile-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    $("#"+form_id+" input.dataFormField").val("")
    if JSON.parse(xhr.responseText).status == "NOK"
#      popup_error(popup_messages.failed_to_add_data)
      popup_error(JSON.parse(xhr.responseText).msg)
    else
      console.log "update profile clicked"
      #ha default lang changed
      if JSON.parse(xhr.responseText).default_lang_changed
        location.pathname = "/"+JSON.parse(xhr.responseText).locale+location.pathname.substr(3)
      popup_success(popup_messages.save_success)
#      location.reload()
  ).on("ajax:error", (e, data, status, xhr) ->
#    popup_error(popup_messages.failed_to_add_data)
    popup_error(JSON.parse(xhr.responseText).msg)
  )

@reset_settings_ui = () ->
  $(".menuitem a.menulink").removeClass("menulink-selected")
  $(".menu-section").addClass("hiddenSection")

@admin_loaded = () ->
  console.log "admin loaded"
  $.ajax "/pages/traffic",
    type: "GET"
    dataType: "json"
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (result, textStatus, jqXHR) ->
      console.log "Successful AJAX call"
      if result['status'] == "OK"
        drawTraffic(result)
      else
        console.log "status nok"


  $("form.traffic-form").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    $("#"+form_id+" input.dataFormField").val("")
    if JSON.parse(xhr.responseText).status == "NOK"
      console.log "nok"
    else
      console.log "ok"
      reset_settings_ui()
      $("#admin-link").addClass("menulink-selected")
      $("#sectionAdmin").removeClass("hiddenSection")
      drawTraffic(data)
      if data.email
        $("#traffic-uinfo p").html(data.email)
      else
        $("#traffic-uinfo p").html("All traffic of site")
  ).on("ajax:error", (e, data, status, xhr) ->
      console.log "err"
  )

  $("#edit-button").click (event) ->
    console.log "edit pressed"

  $("#delete-button").click (event) ->
    console.log "delete pressed"

@drawTraffic = (data) ->
  buckets = 11
  colorScheme = 'rbow2'
  days = [['Monday', 'Mo' ],['Tuesday', 'Tu' ],['Wednesday', 'We' ],['Thursday', 'Th' ],['Friday', 'Fr' ],['Saturday', 'Sa' ],['Sunday', 'Su' ]]
  hours = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', '22', '23']
  d3.select(("#traffic-vis")).classed(colorScheme, true)
  pdata = JSON.parse(data.data)
  date = new Date(pdata[0][1])
  for i in [0..date.getDay()-2]
    t = days.shift()
    days.push(t)
  for i in [0..6]
    newdate = new Date
    newdate.setDate(newdate.getDate() - (6-i));
    days[i][0] = fmt(newdate) + " "+ days[i][0]
  createTiles(hours,days)
  reColorTiles(buckets, pdata)

@createTiles = (hours, days) ->
    html = '<table id="traffic-tiles" class="front">'
    html += '<tr><th><div>&nbsp;</div></th>'
    for  h in [0..hours.length-1]
      html += '<th class="h' + h + '">' + hours[h] + '</th>'
    html += '</tr>';
    for d in [0..days.length-1]
        html += '<tr class="d' + d + '">'
        html += '<th>' + days[d][0] + '</th>'
        for h in [0..hours.length-1]
           html += '<td id="d' + d + 'h' + h + '" class="d' + d + ' h' + h + '"><div class="tile"><div class="face front"></div><div class="face back"></div></div></td>'
        html += '</tr>'
    html += '</table>'
    d3.select("#traffic-vis").html(html)

@reColorTiles = (buckets, pdata) ->
  calcs = getCalcs(pdata)
  range = []
  for i in [1..buckets]
    range.push(i)
  m = 10
  if calcs[1] > 0
    m = calcs[1]
  bucket = d3.scale.quantize().domain([0, m]).range(range)
  side = d3.select("#traffic-tiles").attr('class')
  j = 0;
  for d in [0..6]
    for h in [0..23]
      sel = '#d' + d + 'h' + h + ' .tile .' + side
      val = pdata[j][2]
      j = j + 1;
      #erase all previous bucket designations on this cell
      for i in [1..buckets]
        cls = 'q' + i + '-' + buckets;
        d3.select(sel).classed(cls, false);
      #set new bucket designation for this cell
      v = 1
      if val > 0
        v = bucket(val)
      cls = 'q' + v + '-' + buckets
      d3.select(sel).classed(cls, true)

@getCalcs = (pdata) ->
  min = 0
  max = 0
  for d in [0..pdata.size]
    tot = pdata[d][2]
    if (tot > max)
      max = tot;
  if max > 100
    max = 100;
  v = 10/max;
  max = max * v;
  return [min, max]


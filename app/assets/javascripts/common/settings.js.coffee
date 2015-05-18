

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
    $.ajax "/sync/sync_moves",
      type: "GET"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
        $("#moves-sync-status").html(failure_message)
      success: (result, textStatus, jqXHR) ->
        console.log "Successful AJAX call"
        console.log result
        if result['status'] == "OK"
          $("#moves-sync-status").html("Synced just now <i class='fa fa-check' style='color: green'></i>")
        else
          $("#moves-sync-status").html(failure_message)

  $("#sync-withings-button").click (event) ->
    $("#withings-sync-status").html("Syncing... <i class='fa fa-spinner fa-spin'></i>")
    failure_message = "Sync failed <i class='fa fa-warning' style='color: red'></i>"
    $.ajax "/sync/sync_withings",
      type: "GET"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
        $("#withings-sync-status").html(failure_message)
      success: (result, textStatus, jqXHR) ->
        console.log "Successful AJAX call"
        console.log result
        if result['status'] == "OK"
          $("#withings-sync-status").html("Synced just now <i class='fa fa-check' style='color: green'></i>")
          console.log result['data']
        else
          $("#withings-sync-status").html(failure_message)

  $("#sync-misfit-button").click (event) ->
    $("#misfit-sync-status").html("Syncing... <i class='fa fa-spinner fa-spin'></i>")
    failure_message = "Sync failed <i class='fa fa-warning' style='color: red'></i>"
    $.ajax "/sync/sync_misfit",
      type: "GET"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
        $("#misfit-sync-status").html(failure_message)
      success: (result, textStatus, jqXHR) ->
        console.log "Successful AJAX call"
        console.log result
        if result['status'] == "OK"
          $("#misfit-sync-status").html("Synced just now <i class='fa fa-check' style='color: green'></i>")
          console.log result['data']
        else
          $("#misfit-sync-status").html(failure_message)

  $("#sync-fitbit-button").click (event) ->
    $("#fitbit-sync-status").html("Syncing... <i class='fa fa-spinner fa-spin'></i>")
    failure_message = "Sync failed <i class='fa fa-warning' style='color: red'></i>"
    $.ajax "/sync/sync_fitbit",
      type: "GET"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
        $("#fitbit-sync-status").html(failure_message)
      success: (result, textStatus, jqXHR) ->
        console.log "Successful AJAX call"
        console.log result
        if result['status'] == "OK"
          $("#fitbit-sync-status").html("Synced just now <i class='fa fa-check' style='color: green'></i>")
          console.log result['data']
        else
          $("#fitbit-sync-status").html(failure_message)

  $("#sync-google-button").click (event) ->
    $("#google-sync-status").html("Syncing... <i class='fa fa-spinner fa-spin'></i>")
    failure_message = "Sync failed <i class='fa fa-warning' style='color: red'></i>"
    $.ajax "/sync/sync_google",
      type: "GET"
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "AJAX Error: #{textStatus}"
        $("#google-sync-status").html(failure_message)
      success: (result, textStatus, jqXHR) ->
        console.log "Successful AJAX call"
        console.log result
        if result['status'] == "OK"
          $("#google-sync-status").html("Synced just now <i class='fa fa-check' style='color: green'></i>")
          console.log result['data']
        else
          $("#google-sync-status").html(failure_message)

  $("#edit-profile-button").click (event) ->
    $("#update-profile-info").html("")
    if $('#update-profile-form').hasClass("hidden")
      $('#update-profile-form').removeClass("hidden")
    else
      $('#update-profile-form').addClass("hidden")


  $("#update-profile-button").click (event) ->
    user = $("#edit-profile-form").serialize()
    id = $("#current-user-id")[0].value
    $.ajax '/users/'+id,
      type: 'PUT',
      data: user,
      dataType: 'json'
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "UPDATE user AJAX Error: #{textStatus}"
        $("#update-profile-info").html("Profile update error")
      success: (data, textStatus, jqXHR) ->
        console.log "UPDATE user  Successful AJAX call"
        if data.status == "NOK"
          $("#update-profile-info").html("Profile update error")
        else
          $("#update-profile-info").html("Profile updated successfully")
          $('#update-profile-form').addClass("hidden")

@reset_settings_ui = () ->
  $(".menuitem a.menulink").removeClass("menulink-selected")
  $(".menu-section").addClass("hiddenSection")
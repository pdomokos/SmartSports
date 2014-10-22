

@settings_loaded = () ->
  reset_ui()
  $("#settings-button").addClass("selected")

  $("#disconnect-moves-button").click (event) ->
    console.log "disconnecting Moves..."

  $("#sync-moves-button").click (event) ->
    console.log "syncing Moves..."
    failure_message = "Sync failed <i class='fa fa-warning' style='color: red'></i>"
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
    console.log "syncing Withings..."
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
          $("#moves-sync-status").html(failure_message)
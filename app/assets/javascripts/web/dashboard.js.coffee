@dashboard_loaded = () ->
  console.log("dashboard loaded")

  $("div.app2Menu a.menulink").removeClass("selected")
  $("#dashboard-link").addClass("selected")
  uid = $("#current-user-id")[0].value
  loadPatientNotifications(uid)

  $(document).unbind("click.patientNotif")
  $(document).on("click.patientNotif", "#notificationContainer .showNotifClickArea", @loadForm  )

  $(document).unbind("ajax:success.deleteNotif")
  $(document).on("ajax:success.deleteNotif", "#notificationContainer", (e, data, status, xhr) ->
    console.log "notification dismissed"
    console.log data
    $("#currentForm").addClass("hidden")
    $("#currentForm").html("")
    loadPatientNotifications(uid)
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log "notification dismiss failed"
    console.log e
  )

@loadPatientNotifications = (userId) ->
  url = '/users/' + userId + '/notifications.js?order=desc&limit=5&patient=true&active=true'
  console.log "calling load notifications for: "+userId+" "+url
  $.ajax url,
    type: 'GET',
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "load recent notifications AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "load recent notifications Successful AJAX call"

@loadForm = (evt) ->
  @popup_messages = JSON.parse($("#popup-messages").val())
  cf = evt.currentTarget.querySelector("input.customFormId")
  cfId = null
  if cf
    cfId = cf.value
  notif = evt.currentTarget.querySelector("input.notificationId")
  notifId = null
  if notif
    notifId = notif.value
  console.log "loadform called: id="+cfId
  if cfId
    $.ajax "/custom_forms/"+cfId+".js?target=currentForm",
      type: 'GET',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "load custom form AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        console.log "load custom form Successful AJAX call"

        registerAddCustomForm( () ->
          console.log "dismiss: "+notifId
          $("#dismiss_notif_"+notifId).submit()
        )
        customPreload()
  else
    $("#currentForm").addClass("hidden")
    $("#currentForm").html("")


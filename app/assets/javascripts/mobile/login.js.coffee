@signin_loaded = () ->
  console.log "signin loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $('#username_field').focus()

  $("#loginForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    document.location = "/pages/mobilepage#dietPage"
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log error
    $("#failurePopup").popup("open");
  )
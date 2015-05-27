@signup_loaded = () ->
  console.log "signup loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $('#username_field').focus()
  $("#signupForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    #    redir to main page
    document.location = "/"
  ).on("ajax:error", (e, data, status, error) ->
    console.log data.responseJSON

    popup_error(popup_messages.sign_up_failed)
  )


@signin_loaded = () ->
  console.log "signin loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $('#username_field').focus()

  $("#loginForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

#    redir to main page
    document.location = "/"
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log error
    popup_error(popup_messages.login_failed)
  )


@resetpw_loaded = () ->
  console.log "resetpw loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $("#forgotten_email_field").focus()

  $("#pwResetForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    popup_success(popup_messages.passwd_reset_success)
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log data.responseJSON
    popup_error(popup_messages.password_reset_failed)
  )

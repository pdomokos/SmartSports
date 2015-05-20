@signup_loaded = () ->
  console.log "signup loaded"
  $('#username_field').focus()
  $("#signupForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    #    redir to main page
    document.location = "/"
  ).on("ajax:error", (e, data, status, error) ->
    console.log data.responseJSON

    popup_error("Sign up failed. "+data.responseJSON['msg'])
  )


@signin_loaded = () ->
  console.log "signin loaded"
  $('#username_field').focus()

  $("#loginForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

#    redir to main page
    document.location = "/"
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log error
    popup_error("Login failed")
  )


@resetpw_loaded = () ->
  console.log "resetpw loaded"
  $("#forgotten_email_field").focus()

  $("#pwResetForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    popup_success("A jelszó visszaállítás sikeres, nézze meg a bejövő leveleit.")
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log data.responseJSON
    popup_error("Password reset failed")
  )

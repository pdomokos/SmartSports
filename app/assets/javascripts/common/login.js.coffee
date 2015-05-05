@signup_loaded = () ->
  console.log "signup loaded"
  $('#username_field').focus()

@signin_loaded = () ->
  console.log "signin loaded"
  $('#username_field').focus()

@resetpw_loaded = () ->
  console.log "resetpw loaded"
  $("#forgotten_email_field").focus()
@signup_loaded = () ->
  console.log "signup loaded"
  $('#username_field').watermark('Email address')
  $('#password_field').watermark('Password')
  $('#password_retry_field').watermark('Password Retry')
  $('#username_field').focus()

@signin_loaded = () ->
  console.log "signin loaded"
  $('#username_field').watermark('User name')
  $('#password_field').watermark('Password')
  $('#username_field').focus()

@resetpw_loaded = () ->
  console.log "resetpw loaded"

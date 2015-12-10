@profile_loaded = () ->
  console.log "profile loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $('#firstname_field').focus()
  $('#profile_birth_datepicker').datetimepicker({
    format: 'Y-m-d',
    timepicker: false,
    maxDate: '0',
    minDate: new Date(1900, 1 - 1, 1),
    defaultDate: new Date(1980, 1 - 1, 1)
    onSelectDate: (ct, input) ->
      input.datetimepicker('hide')
    todayButton: true
  })

  $("#profileForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    #    redir to main page
    document.location = "/"+data.locale+"/pages/dashboard"
  ).on("ajax:error", (e, data, status, error) ->
    console.log data.responseJSON
#    popup_error(popup_messages.failed_to_add_data)
    popup_error(data.responseJSON["msg"])
  )
  $("#emptyProfileForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    #    redir to main page
    document.location = "/"+data.locale+"/pages/dashboard"
  ).on("ajax:error", (e, data, status, error) ->
    console.log data.responseJSON
    popup_error(data.responseJSON["msg"])
  )


@signup_loaded = () ->
  console.log "signup loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $('#username_field').focus()
  $("#signupForm").on("ajax:success", (e, data, status, error) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    #    redir to main page
    #    document.location = "/"
    if(data.ok == false)
      popup_error(data.responseJSON["msg"])
    else
      document.location = "/"+data.locale+"/profile/new"
  ).on("ajax:error", (e, data, status, error) ->
    console.log data.responseJSON
    popup_error(data.responseJSON["msg"])
#    popup_error(popup_messages.sign_up_failed)
  )


@signin_loaded = () ->
  console.log "signin loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $('#username_field').focus()

  $(document).unbind("ajax:success.login")
  $(document).on("ajax:success.login", "#loginForm", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
#    redir to main page
    if data.profile
      document.location = "/"
    else
      document.location = "/"+data.locale+"/profile/new"
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log error
    popup_error(xhr.responseJSON["msg"])
#    popup_error(popup_messages.login_failed)
  )


@resetpw_loaded = () ->
  console.log "resetpw loaded"
  popup_messages = JSON.parse($("#popup-messages").val())
  $("#forgotten_email_field").focus()

  $("#pwResetForm").on("ajax:success", (e, data, status, error) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    if data.ok
      popup_success(popup_messages.passwd_reset_success)
      document.location = "/"+data.locale+"/pages/signin"
    else
      popup_error(popup_messages.password_reset_failed)
  ).on("ajax:error", (e, data, status, error) ->
    console.log data.responseJSON
    popup_error(popup_messages.password_reset_failed)
  )

@resetpw_page_loaded = () ->
  console.log "resetpw page loaded"

  $("#pwChangeForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id
    console.log data.locale
    if data.ok
       popup_success(xhr.responseJSON["msg"])
       document.location = "/"+data.locale+"/pages/signin"
    else
      console.log xhr.responseJSON
      popup_error(xhr.responseJSON["msg"])
  ).on("ajax:error", (e, data, status, xhr) ->
    popup_error(xhr.responseJSON["msg"])
    #popup_error(popup_messages.password_reset_failed)
  )
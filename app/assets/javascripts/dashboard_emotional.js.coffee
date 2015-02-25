@register_emotional_cbs = () ->
  self = this
  console.log "register_emotional_cbs()"

  # friendship events
  $("#friend-form-sel").click (event) ->
    self.reset_form_sel()
    $("#friend_name").val("")
    $("#friend-message").addClass("hidden-placed")
    $("#friend-form-div").removeClass("hidden")
    $("#friend-form-sel div.log-sign").removeClass("hidden-placed")
    $("#friend-form-sel").addClass("selected")
    $("#friend_name").focus()

  $("#new-friend-button").click (event) ->
    new_friend_submit_handler(event)

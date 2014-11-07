@friendships_loaded = () ->
  reset_ui()
  $("#friendship-button").addClass("selected")
  $("#new-friendship-button").click (event) ->
    new_friend_submit_handler(event)

@new_friend_submit_handler = (event) ->
  event.preventDefault()
  values = $("#new-friendship-form").serialize()
  console.log values
  $.ajax '/friendships',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE friend AJAX Error: #{textStatus}"

    success: (data, textStatus, jqXHR) ->
      console.log "CREATE friend  Successful AJAX call"
      console.log data


# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@load_notifications = () ->
  notification_limit = 20
  $.ajax '/users/'+$("#current-user-id")[0].value+'/notifications?limit='+notification_limit,
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call"

      i = 0
      $("div#event-list").empty()
      for notif in data
        newactivity = $("#event-template").children().first().clone()
        newid =  "notif-" + i
        newactivity.attr('id', newid)
        if i == 0
          $("div#event-list").html(newactivity)
        else
          newactivity.insertAfter($("div#event-list").children().last())

        $("#"+newid+" i").addClass("fa-paper-plane-o")

        d = fmt(new Date(Date.parse(notif['date'])))

        $("#"+newid+" div div.event-time span").html(d)
        $("#"+newid+" div div.event-title").html(notif['title'])

        activate_link = ""
        if notif['notification_data']
          notif_data = JSON.parse(notif['notification_data'])

          if notif_data['notif_type'] == 'friendreq'
            friend_id = notif_data['friendshipid']
            linkid = newid+"_"+notif_data["friendship_id"]
            activate_link = " <a href='#' id='"+linkid+"'>Manage friends</a>"
            $("#"+newid+" div div.event-details span").html(notif['detail']+activate_link)
            $("#"+linkid).click (evt) ->
              evt.preventDefault()
              reset_form_sel()
              $("#friend-form-div").removeClass("hidden")
              $("#friend-form-sel div.log-sign").removeClass("hidden-placed")
              $("#friend-form-sel").addClass("selected")
        else
          $("#"+newid+" div div.event-details span").html(notif['detail'])
        i += 1

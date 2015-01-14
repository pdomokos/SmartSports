
@dashboard_loaded = () ->
  reset_ui()
  $("#dashboard-button").addClass("selected")
  console.log "dashboard loaded"
  setdate()
  update_summary()
  load_notifications()

  del = (event) ->
    friend_name = event.target.parentElement.firstChild.textContent
    event.target.parentElement.remove()
    $("#pingpong-activity-participant").append(new Option(friend_name, friend_name))

  $("#act-form").on("click", "i.remove-pingpong-participant", del)

  $("#add-pingpong-participant").click (event) ->
    player_sel = [[], [[0,1]], [[0,1], [0, 2], [1,2]], [[[0, 1], [2, 3]], [[0,2], [1,3]], [[0, 3],[1, 2]]]]
    pname = $("#pingpong-activity-participant").val()

    if( pname != null and $("#pingpong-participants span").size() < 3)
      console.log pname
      $("<div><span>"+pname+"</span> <i class=\"fa fa-minus-square text-red remove-pingpong-participant\"></i></div>").appendTo("#pingpong-participants")

      player_arr = [$("#current-user-name").val()]
      for s in $("#pingpong-participants span")
        player_arr.push(s.innerHTML)
      console.log player_arr


      $("#pingpong-activity-participant option[value="+pname+"]").remove()
      npart = $("#pingpong-participants span").size()
      console.log npart
      $("#pingpong-games option").remove()
      $("#pingpong-games-container").removeClass("hidden")
      if npart == 1 or npart == 2
        for g in player_sel[npart]
          game_txt = player_arr[g[0]]+" : "+player_arr[g[1]]
          $("#pingpong-games").append(new Option(game_txt, game_txt))
      else if npart==3
        for g in player_sel[npart]
          game_txt = player_arr[g[0][0]]+" - "+player_arr[g[0][1]] + " : "+ player_arr[g[1][0]]+" - "+player_arr[g[1][1]]
          console.log game_txt
          $("#pingpong-games").append(new Option(game_txt, game_txt))

  $("#act-type").change (event) ->
    act_type =  event.target.value
    $("#act-form-div div.field-temp").addClass("hidden")
    $("#act-form-div div.field."+act_type+"-param").removeClass("hidden")
    $("#pingpong-games-container").addClass("hidden")

  $("#timer-start").click (event) ->
    $("#activity-timer").html("00:00")
    $("#act-form-div div.field-temp").addClass("hidden")
    $("#act-form-div div.field.timer-param").removeClass("hidden")
    $("#new-activity-button").addClass("hidden-placed")
    $("#timer-start").addClass("hidden")
    $("#timer-stop").removeClass("hidden")
    $("#timer-started-at").val(new Date().getTime())

    $("#timer-running").val("true")
    timer_handler = () ->
      if $("#timer-running") and $("#timer-running").val()=="true"
        started = parseInt($("#timer-started-at").val())
        curr = new Date().getTime()
        diff = Math.floor((curr - started)/1000)
        hour = Math.floor(diff/60/60)
        diff = diff - hour*60*60
        minutes = Math.floor(diff/60)
        diff = diff - minutes*60
        seconds = diff
        elapsed = ("0"+minutes.toString()).substr(-2)+":"+("0"+seconds.toString()).substr(-2)
        if hour > 0
          elapsed = ("0"+hour.toString()).substr(-2)+":"+elapsed
        $("#activity-timer").html(elapsed)
        setTimeout( timer_handler, 1000)
    setTimeout(timer_handler, 1000)

  $("#timer-stop").click (event) ->
    $("#new-activity-button").removeClass("hidden")
    $("#timer-start").removeClass("hidden")
    $("#timer-stop").addClass("hidden")
    $("#act-form-div div.field."+$("#act-type").val()+"-param").removeClass("hidden")
    $("#act-form-div div.field.timer-param").addClass("hidden")
    $("#timer-stopped-at").val(new Date().getTime())
    $("#timer-running").val("false")

    date = fmt_hms(new Date(parseInt($("#timer-started-at").val())))
    duration = Math.floor((parseInt($("#timer-stopped-at").val())-parseInt($("#timer-started-at").val()))/(1000*60))
    $("#"+$("#act-type").val()+"-date").val(date)
    $("#"+$("#act-type").val()+"-duration").val(duration)

  $("#act-form-sel").click (event) ->
    reset_form_sel()
    $("#act-form-div").removeClass("hidden")
    $("#act-form-sel div.log-sign").removeClass("hidden-placed")
    $("#act-form-sel").addClass("selected")
    $("#act-message").addClass("hidden-placed")
    $("#act-steps").focus()


  $("#heart-form-sel").click (event) ->
    reset_form_sel()
    $("#heart-form-div").removeClass("hidden")
    $("#meas-message").addClass("hidden-placed")
    $("#heart-form-sel div.log-sign").removeClass("hidden-placed")
    $("#heart-form-sel").addClass("selected")
    $("#meas-sys").focus()

  $("#friend-form-sel").click (event) ->
    reset_form_sel()
    $("#friend_name").val("")
    $("#friend-message").addClass("hidden-placed")
    $("#friend-form-div").removeClass("hidden")
    $("#friend-form-sel div.log-sign").removeClass("hidden-placed")
    $("#friend-form-sel").addClass("selected")
    $("#friend_name").focus()

  $("#new-activity-button").click (event) ->
    new_activity_submit_handler(event)

  $("#new-measurement-button").click (event) ->
    new_measurement_submit_handler(event)

  $("#new-friend-button").click (event) ->
    new_friend_submit_handler(event)


new_friend_submit_handler = (event) ->
  event.preventDefault()
  values = $("#friend-form").serialize()
  console.log values
  $.ajax '/friendships',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (data, textStatus, errorThrown) ->
      console.log "CREATE friend AJAX Error: #{textStatus}"
      console.log data
    success: (data, textStatus, jqXHR) ->
      if data.status == "OK"
        console.log "CREATE friend  Successful AJAX call"
        console.log data
        $("#friend_name").val("")
        $("#friend-message").addClass("hidden-placed")
        load_notifications()
      else
        $("#friend-message").removeClass("hidden-placed")
#        $("#friend-form-div div.friend-message").addClass("red")
        msg = data.msg+" "+"<i class=\"fa fa-exclamation-circle failure\"></i>"
        $("#friend-message").html(msg)

setdate = () ->
  now = new Date(Date.now())
  $(".logform input.date-input").val(fmt_hms(now))

reset_form_sel = () ->
  $("#act-form-div").addClass("hidden")
  $("#heart-form-div").addClass("hidden")
  $("#friend-form-div").addClass("hidden")
  $("#heart-form-sel div.log-sign").addClass("hidden-placed")
  $("#act-form-sel div.log-sign").addClass("hidden-placed")
  $("#friend-form-sel div.log-sign").addClass("hidden-placed")
  $("#heart-form-sel").removeClass("selected")
  $("#act-form-sel").removeClass("selected")
  $("#friend-form-sel").removeClass("selected")
  setdate()

@new_activity_submit_handler = (event) ->
  event.preventDefault()
  values = $("#act-form").serialize()
  $("#act-message").addClass("hidden-placed")
  $("#act-message").html("")
  $.ajax '/activities',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE activity AJAX Error: #{textStatus}"
      $("#act-message").html("Failed to add activity <i class=\"fa fa-exclamation-circle failure\"></i>")
      $("#act-message").removeClass("hidden-placed")
      console.log "fails"
      console.log jqXHR
    success: (data, textStatus, jqXHR) ->
      console.log "CREATE measurements  Successful AJAX call"
      console.log data
      $("#act-message").removeClass("hidden-placed")
      $("#act-message").html("Added activity <i class=\"fa fa-check success\"></i>")

@new_measurement_submit_handler = (event) ->
  event.preventDefault()
  values = $("#heart-form").serialize()
  valuesArr = $("#heart-form").serializeArray()
  $("#meas-message").addClass("hidden-placed")
  console.log valuesArr
  $.ajax '/measurements',
    type: 'POST',
    data: values,
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "CREATE measurement AJAX Error: #{textStatus}"
      $("#meas-message").html("Failed to add measurement <i class=\"fa fa-exclamation-circle failure\"></i>")
      $("#meas-message").removeClass("hidden-placed")
    success: (data, textStatus, jqXHR) ->
      console.log "CREATE measurement  Successful AJAX call"
      console.log data
      $("#meas-message").html("Measurement added <i class=\"fa fa-check success\"></i>")
      $("#meas-message").removeClass("hidden-placed")
      $("#meas-sys").val("")
      $("#meas-dia").val("")
      $("#meas-hr").val("")

load_notifications = () ->
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

update_summary = () ->
  chart_element = "dashboard-summary-container"
  today = new Date(Date.now())
  $.ajax '/users/'+$("#current-user-id")[0].value+"/outline",
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful AJAX call"

      # $("#"+chart_element+" div.chart-date").html("Today")
      $("#"+chart_element+" div.chart-date").html(fmt_words(today))

      sum_steps = data['steps']
      $("#"+chart_element+" div.steps").html(sum_steps)
      percent = (sum_steps/10000.0*100.0).toFixed(1)
      $("#"+chart_element+" div.avg-percent").html(percent+"%")
      draw_percent(chart_element, percent)

      $("#"+chart_element+" div.avg-description").html("of 10,000 steps")
      $("#"+chart_element+" div.km-running").html(data['running'].toFixed(2))
      $("#"+chart_element+" div.km-cycling").html(data['cycling'].toFixed(2))
      $("#"+chart_element+" div.calories").html(Math.round(data['calories']))
      $("#"+chart_element+" div.distance").html(data['distance'].toFixed(2))
      duration_sec = data['activity']
      timestr = get_hour(duration_sec)+"h "+get_min(duration_sec)+"min"
      $("#"+chart_element+" div.duration").html(timestr)

      draw_daily_activity(chart_element, data['profile'])

draw_daily_activity = (chart_element, data) ->

  margin = {top: 30, right: 30, bottom: 30, left: 30}
  aspect = 400/700
  parent_width = $("#"+chart_element).parent().width()
  console.log "parent.width = "+parent_width
  width = parent_width-margin.left-margin.right
  height = aspect*width-margin.top-margin.bottom

  svg = d3.select($("#"+chart_element+" svg.activity-chart-svg")[0])
  svg = svg
    .attr("width", parent_width)
    .attr("height", height+margin.top+margin.bottom)
    .append("g")
      .attr("transform", "translate("+margin.left+","+margin.top+")")

  time_padding = 1
  time_extent = d3.extent(data, (d) -> d.time)
  time_extent[0] = 0
  time_scale = d3.scale.linear().domain(time_extent).range([0, width])

  y_extent = d3.extent( data, (d) -> d.activity )
  y_scale = d3.scale.linear().domain(y_extent).range([height, 0])

  barwidth = width/49.0
  svg
    .selectAll("rect.act")
    .data(data)
    .enter()
    .append("rect")
    .attr("class", "act")
    .attr("x", (d) -> time_scale(d.time)-barwidth/2)
    .attr("y", (d) -> y_scale( d.activity) )
    .attr("width", (d) -> barwidth)
    .attr("height", (d) -> height - y_scale(  d.activity ) )

  time_axis = d3.svg.axis()
    .scale(time_scale)

  svg
    .append("g")
    .attr("class", "x axis")
    .attr("transform", "translate(0 ,"+height+")")
    .call(time_axis)
  svg.
    select(".x.axis")
    .append("text")
    .text("Hour")
    .attr("x", (width / 2) - margin.right)
    .attr("y", margin.bottom / 1.1)

  y_axis = d3.svg.axis()
    .scale(y_scale)
    .orient("left")
  svg
    .append("g")
    .attr("class", "y axis steps")
    .attr("transform", "translate(0, 0)")
    .call(y_axis)
  svg.select(".y.axis")
    .append("text")
    .text("Activity (Steps)")
    .attr("x", -30)
    .attr("y", -10)
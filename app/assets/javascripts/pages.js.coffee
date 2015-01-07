# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@pages_menu = () ->
  console.log "pages layout"
  define_globals()

define_globals = () ->
  window.fmt = d3.time.format("%Y-%m-%d")
  window.fmt_hms = d3.time.format("%Y-%m-%d %H:%M:%S")
  window.fmt_words = d3.time.format("%Y %b %e")
  window.fmt_month_day = d3.time.format("%b %e")
  window.fmt_year = d3.time.format("%Y")
  window.get_hour =  (sec) ->
    Math.floor(sec/60.0/60.0).toString()
  window.get_min =  (sec) ->
    Math.floor((sec%(60*60))/60).toString()

  window.draw_percent = (chart_element, percent) ->
    console.log("draw percent "+chart_element)
    $("#"+chart_element+" svg.goal-percent-indicator").empty()
    svg = d3.select($("#"+chart_element+" svg.goal-percent-indicator")[0])

    fullarc = d3.svg.arc()
    .innerRadius(60)
    .outerRadius(70)
    .startAngle(0)
    .endAngle(2*Math.PI)

    arc = d3.svg.arc()
    .innerRadius(60)
    .outerRadius(70)
    .startAngle(0)
    .endAngle(percent/100*2*Math.PI)

    g = svg
    .append("g")
    .attr("transform", "translate(75, 75)")

    g.append("path")
    .attr("class", "full-arc")
    .attr("d", fullarc)

    g.append("path")
    .attr("class", "percent-arc")
    .attr("d", arc)

@reset_ui = () ->
  $("#browser-menu-tab a.browser-subnav-item").removeClass("selected")
  $("#friend-form-div div.friend-message").addClass("hidden")

  close_modals = () ->
    $("div.friend-select-holder").addClass("hidden")
    $(document).off("click")

  $("i.friend-select-arrow").click (event) ->
    event.stopPropagation()
    $("div.friend-select-holder").removeClass("hidden")
    $(document).click (event) ->
      event.preventDefault()
      close_modals()

  load_friends()

load_friends = () ->
  $.ajax '/users/'+$("#current-user-id")[0].value+'/friendships',
    type: 'GET'
    dataType: 'json'
    error: (jqXHR, textStatus, errorThrown) ->
      console.log "AJAX Error: #{textStatus}"
    success: (data, textStatus, jqXHR) ->
      console.log "Successful friendship call"

      $("div.friend-select-list").empty()
      $("#friend-form div.friend-list").empty()

      if $("#current-user-id")[0].value !=  $("#shown-user-id")[0].value
        add_me()

      for f in data
        if f.other_id.toString() == $("#shown-user-id")[0].value
          continue
        if f.authorized
          newfriend = $("#friend-select-item-template").children().first().clone()
          newid = "f-"+f.id
          newfriend.attr("id", newid)
          $("div.friend-select-list:last-child").append(newfriend)

          $("#"+newid+" .friend-select-item-text").html(f.other_name)
          friend_sel_id = "friend-sel-"+f.other_id
          $("#"+newid+" .friend-select-item-text").attr("id", friend_sel_id)
          $("#"+friend_sel_id).click (evt) ->
            friend_id = evt.target.id.split("-")[-1..]
            u = $("#browser-menu-tab a.browser-subnav-item.selected").attr("href")
            re = new RegExp("[/?]")
            page = u.split(re)[2]
            if page != 'health' and page!= 'training' and page != 'lifestyle'
              page = 'health'
            window.location = "/pages/"+page+"?shown_user="+friend_id

          $("#friend-form div.friend-list:last-child").append("<div>"+f.other_name+" <i class=\"fa fa-check activated\"></i></div>")

          # add to activity participant list
          if $("#pingpong-activity-participant")
            $("#pingpong-activity-participant").append(new Option(f.other_name, f.other_name))
        else
          if f.invited
            $("#friend-form div.friend-list:last-child").append("<div>"+f.other_name+"<span class=\"activate_friend\" id=\"friend_act_"+f.id+"\"> Activate</span></div>")
            $("#friend_act_"+f.id).click (evt) ->
              arr = evt.target.id.split("_")
              fid = arr[arr.length-1]
              $.ajax '/users/'+f.my_id+'/friendships/'+fid+"?cmd=activate",
                type: 'GET'
                dataType: 'json'
                error: (jqXHR, textStatus, errorThrown) ->
                  console.log "AJAX Error: #{textStatus}"
                success: (data, textStatus, jqXHR) ->
                  console.log "Successful activate call"
                  load_friends()

add_me = () ->
  console.log "adding me"
  newfriend = $("#friend-select-item-template").children().first().clone()
  newid = "f-me"
  newfriend.attr("id", newid)
  $("div.friend-select-list:last-child").append(newfriend)
  $("#"+newid+" .friend-select-item-text").html("Me")
  friend_sel_id = "friend-sel-me"
  $("#"+newid+" .friend-select-item-text").attr("id", friend_sel_id)



  $("#"+friend_sel_id).click (evt) ->
    u = $("#browser-menu-tab a.browser-subnav-item.selected").attr("href")
    re = new RegExp("[/?]")
    page = u.split(re)[2]
    window.location = "/pages/"+page
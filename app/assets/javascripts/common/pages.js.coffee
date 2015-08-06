# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@pages_mobile_menu = () ->
  self = this
  console.log "pages mobile"
  define_globals()

  $.mobile.changePage.defaults.allowSamePageTransition = true
  $.mobile.filterable.prototype.options.filterCallback = ( index, searchValue ) ->
    return false


  $("#logoutFormMobile").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    document.location = '/login'
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log e
    console.log xhr
    console.log error
    $("#failurePopup").popup("open")
  )

#  $( document ).on( "swiperight", "#main-page", ( e ) ->
#    console.log e
#    if ( $( ".ui-page-active" ).jqmData( "panel" ) != "open" )
#      if ( e.type == "swiperight" )
#        $( "#menuPanel" ).panel( "open" );
#  )

@pages_menu = () ->
  self = this
  console.log "pages menu"
  define_globals()

  $("#langswitcher").click ->
    console.log "langswitcher clicked"
    lang = this.textContent
    console.log location.href
    $.ajax '/'+lang+'/profile/set_default_lang',
      type: 'POST',
      error: (jqXHR, textStatus, errorThrown) ->
        console.log "set default lang AJAX Error: #{textStatus}"
      success: (data, textStatus, jqXHR) ->
        if location.pathname.startsWith("/en") ||location.pathname.startsWith("/hu")
          location.pathname = "/"+lang+location.pathname.substr(3)
        console.log "set default lang  Successful AJAX call"
        console.log textStatus

  setInterval( () ->
    self.rotateLogo()
    self.changeColor()
  , 1000 * 30)

  @rotateLogo()

  $('img.loginLogo').click () ->
    self.rotateLogo()
    self.changeColor()

  $('#settings-link').click () ->
    console.log "clicked"
    window.location = $("#settings-url")[0].value

  $("#logoutForm").on("ajax:success", (e, data, status, xhr) ->
    form_id = e.currentTarget.id
    console.log "success "+form_id

    #    redir to main page
    document.location = "/"
  ).on("ajax:error", (e, xhr, status, error) ->
    console.log e
    console.log xhr
    console.log error
    popup_messages = JSON.parse($("#popup-messages").val())
    popup_error(popup_messages.logout_failed)
  )

  $('body').on('click', "#infoOkButton", () ->
    $("#infoPopup").addClass("hidden")
  )
  $('body').on('click',"#errorOkButton", () ->
    $("#errorPopup").addClass("hidden")
  )

@rotateLogo = () ->
  $('img.loginLogo').animate({borderSpacing: -360}, {
    step: (now, fx) ->
      $(this).css('-webkit-transform', 'rotate(' + now + 'deg)')
      $(this).css('-moz-transform', 'rotate(' + now + 'deg)')
      $(this).css('transform', 'rotate(' + now + 'deg)')
    , duration: 2000
    }, 'linear')

@colorIndex = 0
@changeColor = () ->
  self = this
  backgrounds = ['#9DCFFE', '#74CED7', '#ffd29b']
  buttonBackgrounds = ['#4FBDF2', '#5DD09A', '#FE9A6C']

  if (self.colorIndex < 2)
    self.colorIndex++
  else
    self.colorIndex = 0

  $('.bgAnimation').animate({backgroundColor: backgrounds[self.colorIndex]}, 2000)
  $('.animButton').animate({
    backgroundColor: buttonBackgrounds[self.colorIndex],
    borderColor: buttonBackgrounds[self.colorIndex]
  }, 2000)
  $('.animField').animate({borderColor: buttonBackgrounds[self.colorIndex]}, 2000)

define_globals = () ->
  window.timepicker_defaults = {
    format: 'Y-m-d H:i',
    step: 5,
    todayButton: true
    onSelectTime: (ct, input) ->
      input.datetimepicker('hide')
  }
  window.moment_fmt = 'YYYY-MM-DD HH:mm'
  window.default_source = "smartdiab"
  window.fmt = d3.time.format("%Y-%m-%d")
  window.fmt_day = d3.time.format("%Y-%m-%d %a")
  window.fmt_hms = d3.time.format("%Y-%m-%d %H:%M:%S")
  window.fmt_hm = d3.time.format("%Y-%m-%d %H:%M")
  window.fmt_words = d3.time.format("%Y %b %e")
  window.fmt_month_day = d3.time.format("%b %e")
  window.fmt_year = d3.time.format("%Y")
  window.get_hour =  (sec) ->
    Math.floor(sec/60.0/60.0).toString()
  window.get_min =  (sec) ->
    Math.floor((sec%(60*60))/60).toString()

  window.draw_percent = (chart_element, percent) ->
    $("#"+chart_element+" svg.goal-percent-indicator").empty()
    svg = d3.select($("#"+chart_element+" svg.goal-percent-indicator")[0])

    if percent == null
      percent = 0
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

  window.capitalize = (word) ->
    if word
      word.charAt(0).toUpperCase() + word.slice 1
    else
      word

  window.get_yesterday_ymd = () ->
    d = new Date()
    d.setDate(d.getDate()-1)
#    d.setHours(0)
#    d.setMinutes(0)
#    d.setSeconds(0)
    return fmt(new Date(d))

  window.get_monday = (date_ymd) ->
    d = new Date(Date.parse(date_ymd))
    dow = d.getDay()
    dow2 = if (dow==0) then 6 else (dow-1)
    d.setDate(d.getDate()-dow2)
    d.setHours(0)
    d.setMinutes(0)
    d.setSeconds(0)
    return new Date(d)

  window.get_sunday = (date_ymd) ->
    d = new Date(Date.parse(date_ymd))
    dow = d.getDay()
    dow2 = if (dow==0) then 6 else (dow-1)

    d.setDate(d.getDate()+6-dow2)
    d.setHours(23)
    d.setMinutes(59)
    d.setSeconds(59)
    return new Date(d)

  window.get_week_activities = (date_ymd, data) ->
    result = {'walking': [], 'running':[], 'cycling': [], 'transport': []}
    keys = ['walking', 'running', 'cycling', 'transport']
    monday = get_monday(date_ymd)
    sunday = get_sunday(date_ymd)
    for k in keys
      if data[k]
        for d in data[k]
          curr = new Date(Date.parse(d.date))
          if curr >= monday and curr<=sunday
            result[k].push(d)
    return result

  window.get_daily_activities = (date, data) ->
    result = {'walking': [], 'running':[], 'cycling': [], 'transport': []}
    walking = if data.walking then data.walking else []
    running = if data.running then data.running else []
    cycling = if data.cycling then data.cycling else []
    transport = if data.transport then data.transport else []

    for d in walking.concat(running.concat(cycling.concat(transport)))
      if fmt(new Date(Date.parse(d.date))) == date
        if d.group
          result[d.group].push(d)
        else
          result['walking'].push(d)
    return result

  window.get_sum_measure = (dat, measure, activity_types) ->
    result = 0.0
    for k in activity_types
      if dat[k]
        for item in dat[k]
          result = result + item[measure]
    return result

  window.remove_accents = (astr) ->
    astr.trim().toLowerCase().replace(/á/g, 'a').replace(/é/g, 'e').replace(/í/g, 'i').replace(/[őöó]/g, 'o').replace(/[üúű]/g, 'u')

  window.food_map_fn = (d) ->
    {
      label: d['name'],
      id: d['id'],
      kcal: d['kcal'],
      fat: d['fat'],
      carb: d['carb'],
      prot: d['prot'],
      categ: d['category']
    }

  window.activity_map_fn = (d) ->
    {
    label: d['name'],
    id: d['id']
    }

  window.illness_map_fn = (d) ->
    {
    label: d['name'],
    id: d['id']
    }

  window.popup_success = (msg, background='#9DCFFE') ->
    $("#infoPopup span.msg").html(msg)
    $("#infoOkButton").css
      background: background
    $("#infoPopup").removeClass("hidden");

  window.popup_error = (msg, background='#9DCFFE') ->
    $("#errorPopup span.msg").html(msg)
    $("#errorOkButton").css
      background: background
    $("#errorPopup").removeClass("hidden");

  window.isempty = (sel) ->
    return $(sel).length==0 || $(sel).val()==""
  window.notnumeric = (sel) ->
    return $(sel).length==0 || $(sel).val()=="" || !isFinite($(sel).val())
  window.positive = (sel) ->
    val = $(sel).val()
    return $(sel).length==0 || val=="" || (isFinite(val) && parseInt(val)>0)
  window.notpositive = (sel) ->
    return !positive(sel)
  window.capitalize = (string) ->
    return string.charAt(0).toUpperCase() + string.slice(1);


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

#  load_friends()

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